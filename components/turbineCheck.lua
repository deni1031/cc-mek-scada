function turbineCheck(turbine, reactor, chat)
	if turbine.getSteamFilledPercentage() == 100 then
		reactor.scram()
		chat.sendMessage(peripheral.getName(turbine)..' is full of steam')
		return false
	end

	if turbine.getEnergyFilledPercentage() == 100 then
		reactor.scram()
		chat.sendMessage(peripheral.getName(turbine)..' is full of energy')
		return false
	end
	
	return true
end