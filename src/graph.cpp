#include "graph.h"

#include <QSGGeometry>
#include <QSGGeometryNode>
#include <QSGFlatColorMaterial>

#include <qmath.h>

class Graph::Entry
{
public:
    Entry(const QDateTime &t, qreal v) : time(t), value(v) {}
    QDateTime time;
    qreal value;
};

Graph::Graph(QQuickItem *parent) :
    QQuickItem(parent),
    m_color(Qt::white),
    m_lineWidth(2),
    m_minValue(0),
    m_maxValue(0),
    m_timestampKey("timestamp"),
    m_valueKey("value")
{
    setFlag(ItemHasContents);
    setClip(true);
}

Graph::~Graph()
{
    qDeleteAll(m_paintData);
    // It may be too early to delete nodes at this point
    const int n = m_nodes.count();
    QSGNode *const *nodes = m_nodes.constData();
    for (int i = 0; i < n; i++) {
        QSGNode *node = nodes[i];
        if (node->parent()) {
            // Let SG do it
            node->setFlag(QSGNode::OwnedByParent);
        } else {
            delete node;
        }
    }
}

void Graph::setColor(const QColor &color)
{
    if (m_color != color) {
        m_color = color;
        const int n = m_nodes.count();
        QSGNode *const *nodes = m_nodes.constData();
        for (int i = 0; i < n; i++) {
            QSGGeometryNode *node = (QSGGeometryNode*)nodes[i];
            QSGFlatColorMaterial *m = (QSGFlatColorMaterial*)node->material();
            m->setColor(color);
            node->markDirty(QSGNode::DirtyMaterial);
        }
        emit colorChanged();
    }
}

void Graph::setLineWidth(qreal lineWidth)
{
    if (m_lineWidth != lineWidth) {
        m_lineWidth = lineWidth;
        emit lineWidthChanged();
        update();
    }
}

void Graph::setMinValue(qreal value)
{
    if (m_minValue != value) {
        m_minValue = value;
        emit minValueChanged();
        update();
    }
}

void Graph::setMaxValue(qreal value)
{
    if (m_maxValue != value) {
        m_maxValue = value;
        emit maxValueChanged();
        update();
    }
}

void Graph::setMinTime(const QDateTime &t)
{
    if (m_minTime != t) {
        m_minTime = t;
        emit minTimeChanged();
        update();
    }
}

void Graph::setMaxTime(const QDateTime &t)
{
    if (m_maxTime != t) {
        m_maxTime = t;
        emit maxTimeChanged();
        update();
    }
}

void Graph::setData(const QVariantList &data)
{
    int k = 0;
    const int n = data.count();
    bool changed = false;
    for (int i = 0; i < n; i++) {
        bool ok;
        const QVariantMap dataEntry(data.at(i).toMap());
        const QDateTime time(dataEntry.value(m_timestampKey).toDateTime());
        const qreal value = dataEntry.value(m_valueKey).toReal(&ok);
        if (time.isValid() && ok) {
            if (k < m_paintData.count()) {
                Entry *entry = m_paintData.at(k++);
                if (entry->value != value) {
                    entry->value = value;
                    changed = true;
                }
                if (entry->time != time) {
                    entry->time = time;
                    changed = true;
                }
            } else {
                m_paintData.append(new Entry(time, value));
                changed = true;
                k++;
            }
        } else {
            qWarning() << i << dataEntry;
        }
    }
    while (m_paintData.count() > k) {
        delete m_paintData.takeLast();
        changed = true;
    }
    if (changed) {
        m_data = data;
        emit dataChanged();
        update();
    }
}

void Graph::updateCircleGeometry(QSGGeometry::Point2D *v, float x0, float y0, float r, int n)
{
    v[0].x = x0;
    v[0].y = y0;
    for (int i = 0; i < n; i++) {
        const float theta = i * 2 * M_PI / n;
        v[i + 1].x = x0 + r * cosf(theta);
        v[i + 1].y = y0 + r * sinf(theta);
    }
    v[n + 1] = v[1];
}

void Graph::updateRectGeometry(QSGGeometry::Point2D *v, float x1, float y1, float x2, float y2, float thick)
{
    if (x1 == x2 || y1 == y2) {
        // Vertical or horizontal line
        const bool vertical = (x1 == x2);
        const float d = thick/2;
        const float xmin = vertical ? (x1 - d) : qMin(x1, x2);
        const float xmax = vertical ? (x1 + d) : qMax(x1, x2);
        const float ymin = vertical ? qMax(y1, y2) : (y1 - d);
        const float ymax = vertical ? qMax(y1, y2) : (y1 + d);
        v[0].x = xmin; v[0].y = ymin;
        v[1].x = xmin; v[1].y = ymax;
        v[2].x = xmax; v[2].y = ymax;
        v[3].x = xmax; v[3].y = ymin;
    } else {
        // Rotated rectangle
        const float a = atanf((y2 - y1)/(x2 - x1));
        const float dx = sinf(a) * thick / 2;
        const float dy = cosf(a) * thick / 2;
        v[0].x = x1 + dx; v[0].y = y1 - dy;
        v[1].x = x1 - dx; v[1].y = y1 + dy;
        v[2].x = x2 - dx; v[2].y = y2 + dy;
        v[3].x = x2 + dx; v[3].y = y2 - dy;
    }
}

QSGGeometry *Graph::newCircleGeometry(float x, float y, float radius, int n)
{
    QSGGeometry *g = new QSGGeometry(QSGGeometry::defaultAttributes_Point2D(), n + 2);
    updateCircleGeometry(g->vertexDataAsPoint2D(), x, y, radius, n);
    g->setDrawingMode(GL_TRIANGLE_FAN);
    return g;
}

QSGGeometry *Graph::newRectGeometry(float x1, float y1, float x2, float y2, float thick)
{
    QSGGeometry *g = new QSGGeometry(QSGGeometry::defaultAttributes_Point2D(), 4);
    updateRectGeometry(g->vertexDataAsPoint2D(), x1, y1, x2, y2, thick);
    g->setDrawingMode(GL_TRIANGLE_FAN);
    return g;
}

#define CIRCLE_NODES(r) roundf(8.f * (r))

QSGGeometry *Graph::newNodeGeometry(float x1, float y1, float x2, float y2, float thick)
{
    if (x1 == x2 && y1 == y2) {
        const float r = thick/2.f;
        return newCircleGeometry(x1, y1, r, CIRCLE_NODES(r));
    } else {
        return newRectGeometry(x1, y1, x2, y2, thick);
    }
}

void Graph::updateNodeGeometry(QSGGeometryNode *node, float x1, float y1, float x2, float y2, float thick)
{
    QSGGeometry *g = node->geometry();
    if (x1 == x2 && y1 == y2) {
        // Dot
        const float r = thick/2.f;
        const int n = CIRCLE_NODES(r);
        if (g->vertexCount() == (n + 2)) {
            updateCircleGeometry(g->vertexDataAsPoint2D(), x1, y1, r, n);
            node->markDirty(QSGNode::DirtyGeometry);
        } else {
            node->setGeometry(newCircleGeometry(x1, y1, r, n));
        }
    } else {
        if (g->vertexCount() == 4) {
            updateRectGeometry(g->vertexDataAsPoint2D(), x1, y1, x2, y2, thick);
            node->markDirty(QSGNode::DirtyGeometry);
        } else {
            node->setGeometry(newNodeGeometry(x1, y1, x2, y2, thick));
        }
    }
}

QSGGeometryNode *Graph::newNode(float x1, float y1, float x2, float y2)
{
    QSGFlatColorMaterial *m = new QSGFlatColorMaterial;
    m->setColor(m_color);
    QSGGeometryNode *node = new QSGGeometryNode;
    node->setGeometry(newNodeGeometry(x1, y1, x2, y2, m_lineWidth));
    node->setMaterial(m);
    node->setFlag(QSGNode::OwnsGeometry);
    node->setFlag(QSGNode::OwnsMaterial);
    node->setFlag(QSGNode::OwnedByParent, false); // We manage those
    return node;
}

bool Graph::lineVisible(float x1, float y1, float x2, float y2, float w, float h)
{
    if ((x1 < 0 && x2 < 0) || (x1 >= w && x2 >= w) ||
        (y1 < 0 && y2 < 0) || (y1 >= h && y2 >= h)) {
        return false;
    }
    // Yeah, some cases will slip through but getting it 100% right
    // won't save us much, so let's keep it simple.
    return true;
}

QSGNode *Graph::updatePaintNode(QSGNode *paintNode, UpdatePaintNodeData *)
{
    if (m_data.isEmpty()) {
        qDeleteAll(m_nodes);
        m_nodes.resize(0);
        delete paintNode;
        return Q_NULLPTR;
    } else {
        if (!paintNode) {
            paintNode = new QSGNode;
        }

        const float w = width();
        const float h = height();
        if (w > 0 && h > 0 && m_minValue < m_maxValue &&
            m_minTime.isValid() && m_maxTime.isValid() &&
            m_minTime < m_maxTime) {
            const float timeSpan = m_minTime.msecsTo(m_maxTime);
            const float valueSpan = m_maxValue - m_minValue;
            const Entry *lastEntry = Q_NULLPTR;
            float lastX = 0, lastY = 0;

            // Reuse the existing nodes
            QSGNode *node = paintNode->firstChild();
            const int n = m_paintData.count();
            for (int i = 0; i < n; i++) {
                const Entry *entry = m_paintData.at(i);
                const float x = w * m_minTime.msecsTo(entry->time) / timeSpan;
                const float y = h * (m_maxValue - entry->value) / valueSpan;
                if (lastEntry && lineVisible(lastX, lastY, x, y, w, h)) {
                    if (node) {
                        updateNodeGeometry((QSGGeometryNode*)node, lastX, lastY, x, y, m_lineWidth);
                    } else {
                        node = newNode(lastX, lastY, x, y);
                        paintNode->appendChildNode(node);
                        m_nodes.append(node);
                    }
                    node = node->nextSibling();
                }
                lastEntry = entry;
                lastX = x;
                lastY = y;
            }

            // Drop nodes that we no longer need
            if (node) {
                QSGNode *last;
                // Remove nodes that we no longer need. This may look dangerous
                // but the last unused node must be in m_nodes list.
                do {
                    last = m_nodes.takeLast();
                    paintNode->removeChildNode(last);
                    delete last;
                } while (last != node);
            }
            m_nodes.squeeze();
        } else {
            paintNode->removeAllChildNodes();   // This doesn't delete nodes
            qDeleteAll(m_nodes);                // But this does
            m_nodes.resize(0);
        }

        qDebug() << m_nodes.count();
        return paintNode;
    }
}
