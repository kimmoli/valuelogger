#ifndef GRAPH_H
#define GRAPH_H

#include <QColor>
#include <QDateTime>
#include <QQuickItem>
#include <QVariantList>
#include <QSGGeometry>
#include <QSGNode>

class Graph : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal lineWidth READ lineWidth WRITE setLineWidth NOTIFY lineWidthChanged)
    Q_PROPERTY(qreal minValue READ minValue WRITE setMinValue NOTIFY minValueChanged)
    Q_PROPERTY(qreal maxValue READ maxValue WRITE setMaxValue NOTIFY maxValueChanged)
    Q_PROPERTY(QDateTime minTime READ minTime WRITE setMinTime NOTIFY minTimeChanged)
    Q_PROPERTY(QDateTime maxTime READ maxTime WRITE setMaxTime NOTIFY maxTimeChanged)
    Q_PROPERTY(QVariantList data READ data WRITE setData NOTIFY dataChanged)

public:
    explicit Graph(QQuickItem *parent = Q_NULLPTR);
    ~Graph();

    const QColor &color() const { return m_color; }
    void setColor(const QColor &color);

    qreal lineWidth() const { return m_lineWidth; }
    void setLineWidth(qreal lineWidth);

    qreal minValue() const { return m_minValue; }
    void setMinValue(qreal value);

    qreal maxValue() const { return m_maxValue; }
    void setMaxValue(qreal value);

    const QDateTime &minTime() const { return m_minTime; }
    void setMinTime(const QDateTime &t);

    const QDateTime &maxTime() const { return m_maxTime; }
    void setMaxTime(const QDateTime &t);

    const QVariantList &data() const { return m_data; }
    void setData(const QVariantList &data);

protected:
    QSGNode *updatePaintNode(QSGNode *, UpdatePaintNodeData *) Q_DECL_OVERRIDE;

private:
    static void updateCircleGeometry(QSGGeometry::Point2D *v, float x0, float y0, float r, int n);
    static void updateRectGeometry(QSGGeometry::Point2D *v, float x1, float y1, float x2, float y2, float thick);
    static void updateNodeGeometry(QSGGeometryNode *node, float x1, float y1, float x2, float y2, float thick);
    static QSGGeometry *newCircleGeometry(float x, float y, float r, int n);
    static QSGGeometry *newRectGeometry(float x1, float y1, float x2, float y2, float thick);
    static QSGGeometry *newNodeGeometry(float x1, float y1, float x2, float y2, float thick);
    static bool lineVisible(float x1, float y1, float x2, float y2, float w, float h);
    QSGGeometryNode *newNode(float x1, float y1, float x2, float y2);

signals:
    void colorChanged();
    void lineWidthChanged();
    void minValueChanged();
    void maxValueChanged();
    void minTimeChanged();
    void maxTimeChanged();
    void dataChanged();

private:
    class Entry;
    QColor m_color;
    qreal m_lineWidth;
    qreal m_minValue;
    qreal m_maxValue;
    QDateTime m_minTime;
    QDateTime m_maxTime;
    QString m_timestampKey;
    QString m_valueKey;
    QVariantList m_data;
    QList<Entry*> m_paintData;
    QVector<QSGNode*> m_nodes;
};

#endif // GRAPH_H
