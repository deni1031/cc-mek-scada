function reactorCheck(reactor, chat)
	if reactor.getCoolantFilledPercentage() > 50 then
		reactor.scram()
		chat.sendMessage('reactor does not contain at least 50% of coolant')
		return false
	end

	if reactor.getWasteFilledPercentage() == 100 then
		reactor.scram()
		chat.sendMessage('reactor does not contain at least 50% of coolant')
		return false
	end

	if reactor.getHeatedCoolantFilledPercentage() == 100 then
		reactor.scram()
		chat.sendMessage('reactor is full of heated coolant')
		return false
	end

	if reactor.getTemperature() > 500 then
		reactor.scram()
		chat.sendMessage('High Temperature!')
		return false
	end

	local fuel = reactor.getFuel()

	if fuel.amount < 100 then
		fuel.amount = fuel.amount / 1000
		chat.sendMessage('reactor\'s fuel level: '..fuel.amount..'B')
		return true
	end

	return true
end