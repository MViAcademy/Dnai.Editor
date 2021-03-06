#ifndef INPUTCONTROLLER_H
#define INPUTCONTROLLER_H

#include "dnai/baseio.h"

namespace dnai
{
	namespace controllers
	{
		class InputController : public BaseIo
		{
        public:
            explicit InputController(enums::IoTypeRessouce::IoType t, QQuickItem *parent);

			/**
			* \brief Connect linkable together, create a link, and keep a reference on the visual curve
			* \param linkable
			* \param curve
			* \return Link *
			*/
			Link *connect(ALinkable *linkable, views::BezierCurve *curve) override;


            Link *asyncConnect(ALinkable *linkable) override;
		};

	}
}

#endif // INPUTCONTROLLER_H
