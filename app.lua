require('components/turbineCheck')
require('components/reactorCheck')
local chatUI = require('components/chatUI')

function Check(reactor, turbine_1, turbine_2, chat)
	if reactor.getStatus() ~= true then
		if turbineCheck(turbine_1, reactor, chat) ~= true then
			io.write('turbine 1 - Failed (not good!)\n')
		else
		  io.write('turbine 1 - OK\n')
		end

		if turbineCheck(turbine_2, reactor, chat) ~= true then
			io.write('turbine 2 - Failed (not good!)\n')
		else
		  io.write('turbine 2 - OK\n')
		end

		if reactorCheck(reactor, chat) ~= true then
			io.write('reactor - Failed (not good!)\n')
		else
			io.write('reactor - OK\n')
		end

		reactor.activate()
	end
end

function main()
	local reactor = peripheral.wrap('fissionReactorLogicAdapter_0') or error('reactor not connected')
	local turbine_1 = peripheral.wrap('turbineValve_0') or error('first turbine is not connected')
	local turbine_2 = peripheral.wrap('turbineValve_1') or error('second turbine is not connected')
	local chat = peripheral.find('chatBox') or error('chat box is not connected')

	while reactor.getStatus() == true do

		turbineCheck(turbine_1, reactor, chat)
		turbineCheck(turbine_2, reactor, chat)

		sleep(8)

		reactorCheck(reactor, chat)

		sleep(8)

	end
end

parallel.waitForAny(main, chatUI)