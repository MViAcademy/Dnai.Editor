#ifndef DEBUGDECORATOR_H
#define DEBUGDECORATOR_H
#include "commanddecorator.h"

class DebugDecorator : public CommandDecorator
{
public:
	explicit DebugDecorator(ICommand *decoratedCommand);

	/**
	* \brief Execute the command
	*/
	void execute() const override;
	
	/**
	* \brief Reverse the command
	*/
	void unExcute() const override;

};

#endif // DEBUGDECORATOR_H