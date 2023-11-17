-- get turbine actual status and values of it's production
local function getStatusTurbine(turbine)
	local status = {}

	status.steam = turbine.getSteam() / 1000
	status.steamCapacity = turbine.getSteamCapacity() / 1000
	status.steamFilledPercentage = turbine.getSteamFilledPercentage()..'%'

	local energyRaw = turbine.getEnergy()

	status.energy = 
		energyRaw < 1000000 and energyRaw / 1000 ..'K' or
		energyRaw >= 1000000 and energyRaw / 1000000 ..'M'or
		energyRaw >= 1000000000 and energyRaw / 1000000000 ..'G'

	status.energyCapacity = turbine.getMaxEnergy() / 1000000000
	status.energyFilledPercentage = turbine.getEnergyFilledPercentage()..'%'

	status.productionRate = turbine.getProductionRate()
	status.maxProduction = turbine.getMaxProduction()
	status.maxFlowrate = turbine.getMaxFlowrate() / 1000
	status.maxWaterOutput = turbine.getMaxWaterOutput() / 1000

	return status
end

-- get reactor actual status and values of it's production
local function getReactorStatus(reactor)
	local status = {} -- todo change returns

	status.status = reactor.getStatus() == true and 'running' or 'inactive'
	status.temp = reactor.getTemperature() - 273.15
	status.damagePercent = reactor.getDamagePercent()..'%'

	status.fuel = reactor.getFuel()
	status.fuelCapacity = reactor.getFuelCapacity() / 1000
	status.fuelFilledPercentage = reactor.getFuelFilledPercentage()..'%'

	status.waste = reactor.getWaste()
	status.wasteCapacity = reactor.getWasteCapacity() / 1000
	status.wasteFilledPercentage = reactor.getWasteFilledPercentage()..'%'

	status.burnRate = reactor.getBurnRate()
	status.actualBurnRate = reactor.getActualBurnRate()
	status.actualToSetBurnRatePercentage = status.actualBurnRate / status.burnRate * 100 ..'%'
	status.maxBurnRate = reactor.getMaxBurnRate()

	status.coolant = reactor.getCoolant()
	status.coolantCapacity = reactor.getCoolantCapacity() / 1000
	status.coolantFilledPercentage = reactor.getCoolantFilledPercentage()..'%'

	status.heatedCoolant = reactor.getHeatedCoolant()
	status.heatedCoolantCapacity = reactor.getHeatedCoolantCapacity() / 1000
	status.heatedCoolantFilledPercentage = reactor.getHeatedCoolantFilledPercentage()..'%'

	status.heatingRate = reactor.getHeatingRate()
	status.heatCapacity = reactor.getHeatCapacity()
	status.environmentalLoss = reactor.getEnvironmentalLoss()
	status.boilEfficiency = reactor.getBoilEfficiency()
	status.isForceDisabled = reactor.isForceDisabled() == 'false' and 'Yes' or 'No'

	return status
end

-- get color based on percentage in input
local function amountBasedColor(amount)
	return 
		amount >= 80 and '#AA0000' or
		amount >= 75 and '#FFAA00' or
		amount >= 60 and '#FFFF55' or
		amount <= 50 and '#55FF55'
end

-- creates message to that will be sent about turbines
local function createTurbineStatusMessage(turbines)
	local turbinesStatus = {}
	for k, v in pairs(turbines) do
		turbinesStatus[#turbinesStatus + 1] = getStatusTurbine(v)
	end

	local messages = {}

	for i=1, #turbinesStatus, 1 do
		messages[#messages + 1] = textutils.serialiseJSON({
			{
				text = string.format('Turbine no. %dn', i),
				bold = true,
				color = '#5555FF'
			},
			{
				text = 'Steam filled: ',
			},
			{
				text = string.format('(%04sB/%04sB (%03s)\n', turbinesStatus[i].steam, turbinesStatus[i].steamCapacity, turbinesStatus[i].steamFilledPercentage),
				color = amountBasedColor(tonumber(turbinesStatus[i].steamFilledPercentage:sub(1,-2))),
			},
			{
				text = 'Energy gathered: ',
			},
			{
				text = string.format('%sFE/%sFE (%03s)\n', turbinesStatus[i].energy, turbinesStatus[i].energyCapacity, turbinesStatus[i].energyFilledPercentage),
				color = amountBasedColor(tonumber(turbinesStatus[i].energyFilledPercentage:sub(1,-2)))
			},
			{
				text = 'Production rate: ',
			},
			{
				text = string.format('%d/%d', turbinesStatus[i].productionRate, turbinesStatus[i].maxProduction),
				hoverEvent = {
					action = 'show_text',
					value = string.format('Max flowrate: %s\nMax water output: %s', turbinesStatus[i].maxFlowrate, turbinesStatus[i].maxWaterOutput),
				},
			},
		})
	end

	return messages
end

-- creates message to that will be sent about reactor
local function createReactorStatusMessage(reactor)
	local status = getReactorStatus(reactor)

	local message = textutils.serialiseJSON({
		{
			text = 'Reactor\n',
			color = '#5555FF'
		},
		{
			text = 'Status: '
		},
		{
			text = string.format('%s\n', status.status),
			color = status.status == 'running' and '#00AA00' or '#FF5555',
		},
		{
			text = 'Temperature: '
		},
		{
			text = string.format('%f°C\n', status.temp),
		},
		{
			text = 'Damage: '
		},
		{
			text = string.format('%03s\n', status.damagePercent),
			color = amountBasedColor(tonumber(status.damagePercent:sub(1,-2))),
		},
		{
			text = 'Fuel: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.fuel.amount / 1000, status.fuelCapacity, status.fuelFilledPercentage),
			color = amountBasedColor(tonumber(status.fuelFilledPercentage:sub(1,-2)))
		},
		{
			text = 'Waste: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.waste.amount / 1000, status.wasteCapacity, status.wasteFilledPercentage),
			color = amountBasedColor(tonumber(status.wasteFilledPercentage:sub(1,-2)))
		},
		{
			text = 'Coolant: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.coolant.amount / 1000, status.coolantCapacity, status.coolantFilledPercentage),
			color = amountBasedColor(tonumber(status.coolantFilledPercentage:sub(1,-2)))
		},
		{
			text = 'Heated coolant: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.heatedCoolant.amount / 1000, status.heatedCoolantCapacity, status.heatedCoolantFilledPercentage),
			color = amountBasedColor(tonumber(status.heatedCoolantFilledPercentage:sub(1,-2)))
		},
		{
			text = 'Burn rate:' 
		},
		{
			text = string.format('%fmB/%fmB\n', status.burnRate, status.maxBurnRate),
			hoverEvent = {
				action = 'show_text',
				value = string.format('Actual to set burn rate: %f/%f (%s)', status.burnRate, status.actualBurnRate, status.actualToSetBurnRatePercentage)
			},
		},
		{
			text = 'Statistics: \n'
		},
		{
			text = string.format('  Heating rate: %f\nHeat capacity: %f\nEnviromental loss: %f\nBoil efficiency: %f\nForce: %s', status.heatingRate, status.heatCapacity, status.environmentalLoss, status.boilEfficiency, status.isForceDisabled)
		}
	})

	return message
end

-- main function operating power plant and relaying it's status by chat
return function ()
	local reactor = peripheral.wrap('fissionReactorLogicAdapter_0') or error('reactor not connected')
	local turbine_1 = peripheral.wrap('turbineValve_0') or error('first turbine is not connected')
	local turbine_2 = peripheral.wrap('turbineValve_1') or error('second turbine is not connected')
	local chat = peripheral.find('chatBox') or error('chat box is not connected')

	local configIO = require('configOperations') or error('could not load config file handles',1)

	while chat ~= nil do
		local event, username, message, uuid, isHidden = os.pullEvent('chat')
		local config = configIO.getFromFile() or error('unable to load configuration',1)
		if message:find('!turbines') then
			if message:find('status') then
				local statusMessage = createTurbineStatusMessage(turbines, chat)
				if isHidden or message:find('-h') then
					for i = 1, 2, 1 do
						chat.sendFormattedMessageToPlayer(statusMessage[i], username, 'Turbine', '<>', '#5555FF')
					end
				else
					for i = 1, 2, 1 do
						chat.sendFormattedMessage(statusMessage[i], 'Turbine', '<>', '#5555FF')
					end
				end
			end
			
		elseif message:find('!reactor') then
			if message:find('status') then
				local statusMessage = createReactorStatusMessage(reactor)
				if isHidden or message:find('-h') then
					chat.sendFormattedMessageToPlayer(statusMessage, username, 'Reactor', '<>', '#5555FF')
				else
					chat.sendFormattedMessage(statusMessage, 'Reactor', '<>', '#5555FF')
				end
			end
		end
	end
end