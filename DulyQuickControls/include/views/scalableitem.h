#ifndef SCALABLEITEM_H
#define SCALABLEITEM_H
#include <qglobal.h>
#include <QtQuick/QQuickItem>

#include "iscalable.h"

namespace duly_gui
{
	namespace views
	{
		class ScalableItem : public QQuickItem, public IScalable
		{
			Q_OBJECT
				Q_PROPERTY(qreal scaleFactor READ scaleFactor WRITE setScaleFactor NOTIFY scaleFactorChanged)

		public:
			explicit ScalableItem(QQuickItem *parent = nullptr);

			qreal scaleFactor() const override { return m_scaleFactor; }
			virtual void setScaleFactor(qreal s) = 0;
			virtual QPointF scalePos() const override;
			virtual QPointF realPos() const override;
			virtual void translatePos(const QPointF &);

		signals:
			void scaleFactorChanged(qreal scale);

		protected:
			qreal m_scaleFactor;
			QPointF m_realPos;
		};
	}
}

#endif // SCALABLEITEM_H
