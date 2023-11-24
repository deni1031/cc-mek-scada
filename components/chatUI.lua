-- formats a number with a fixed number of decimal places
function toFixed(number, decimalPlaces)
  local formatString = string.format("%%.%df", decimalPlaces)
  return string.format(formatString, number)
end

-- get turbine actual status and values of it's production
local function getStatusTurbine(turbine)
	local status = {}

	status.steam = turbine.getSteam()
	status.steam.amount = status.steam.amount / 1000

	status.steamCapacity = turbine.getSteamCapacity() / 1000
	status.steamFilledPercentage = turbine.getSteamFilledPercentage()

	local energyRaw = turbine.getEnergy()

	status.energy = 
		energyRaw < 1000000 and energyRaw / 1000 ..'K' or
		energyRaw >= 1000000 and energyRaw / 1000000 ..'M'or
		energyRaw >= 1000000000 and energyRaw / 1000000000 ..'G'
	status.energy = toFixed(status.energy, 2)

	status.energyCapacity = toFixed(turbine.getMaxEnergy() / 1000000000, 2)
	status.energyFilledPercentage = toFixed(turbine.getEnergyFilledPercentage(), 2)

	status.productionRate = toFixed(turbine.getProductionRate(), 2)
	status.maxProduction = toFixed(turbine.getMaxProduction(), 2)
	status.maxFlowRate = toFixed(turbine.getMaxFlowRate() / 1000, 2)
	status.maxWaterOutput = toFixed(turbine.getMaxWaterOutput() / 1000, 2)

	return status
end

-- get reactor actual status and values of it's production
local function getReactorStatus(reactor)
	local status = {} -- todo change returns

	status.status = reactor.getStatus() == true and 'running' or 'inactive'
	status.temp = toFixed(reactor.getTemperature() - 273.15, 2)
	status.damagePercent = toFixed(reactor.getDamagePercent(), 2)

	status.fuel = toFixed(reactor.getFuel(), 2)
	status.fuelCapacity = toFixed(reactor.getFuelCapacity() / 1000, 2)
	status.fuelFilledPercentage = toFixed(reactor.getFuelFilledPercentage(), 2)

	status.waste = toFixed(reactor.getWaste(), 2)
	status.wasteCapacity = toFixed(reactor.getWasteCapacity() / 1000, 2)
	status.wasteFilledPercentage = toFixed(reactor.getWasteFilledPercentage(), 2)

	status.burnRate = toFixed(reactor.getBurnRate(), 2)
	status.actualBurnRate = toFixed(reactor.getActualBurnRate(), 2)
	status.actualToSetBurnRatePercentage = toFixed(status.actualBurnRate / status.burnRate * 100 ..'%', 2)
	status.maxBurnRate = toFixed(reactor.getMaxBurnRate(), 2)

	status.coolant = toFixed(reactor.getCoolant(), 2)
	status.coolantCapacity = toFixed(reactor.getCoolantCapacity() / 1000, 2)
	status.coolantFilledPercentage = toFixed(reactor.getCoolantFilledPercentage(), 2)

	status.heatedCoolant = toFixed(reactor.getHeatedCoolant(), 2)
	status.heatedCoolantCapacity = toFixed(reactor.getHeatedCoolantCapacity() / 1000, 2)
	status.heatedCoolantFilledPercentage = toFixed(reactor.getHeatedCoolantFilledPercentage(), 2)

	status.heatingRate = toFixed(reactor.getHeatingRate(), 2)
	status.heatCapacity = toFixed(reactor.getHeatCapacity(), 2)
	status.environmentalLoss = toFixed(reactor.getEnvironmentalLoss(), 2)
	status.boilEfficiency = toFixed(reactor.getBoilEfficiency(), 2)
	status.isForceDisabled = reactor.isForceDisabled() == 'false' and 'Yes' or 'No'

	return status
end

-- get color based on Percentage in input
local function amountBasedColor(amount)
  return amount >= 80 and '#AA0000' or
      amount >= 75 and '#FFAA00' or
      amount >= 60 and '#FFFF55' or
      amount > 50 and '#FFFF55' or
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
				text = '\n'
			},
			{
				text = 'Steam filled: ',
			},
			{
				text = string.format('(%04sB/%04sB (%03s)', turbinesStatus[i].steam.amount, turbinesStatus[i].steamCapacity, turbinesStatus[i].steamFilledPercentage..'%'),
				color = amountBasedColor(tonumber(turbinesStatus[i].steamFilledPercentage)),
			},
			{
				text = 'Energy gathered: ',
			},
			{
				text = string.format('%sFE/%sFE (%03s)\n', turbinesStatus[i].energy, turbinesStatus[i].energyCapacity, turbinesStatus[i].energyFilledPercentage..'%'),
				color = amountBasedColor(tonumber(turbinesStatus[i].energyFilledPercentage))
			},
			{
				text = 'Production rate: ',
			},
			{
				text = string.format('%d/%d', turbinesStatus[i].productionRate, turbinesStatus[i].maxProduction),
				hoverEvent = {
					action = 'show_text',
					value = string.format('Max flowrate: %s\nMax water output: %s', turbinesStatus[i].maxFlowRate, turbinesStatus[i].maxWaterOutput),
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
			text = string.format('%03s\n', status.damagePercent..'%'),
			color = amountBasedColor(tonumber(status.damagePercent)),
		},
		{
			text = 'Fuel: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.fuel.amount / 1000, status.fuelCapacity, status.fuelFilledPercentage..'%'),
			color = amountBasedColor(tonumber(status.fuelFilledPercentage))
		},
		{
			text = 'Waste: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.waste.amount / 1000, status.wasteCapacity, status.wasteFilledPercentage..'%'),
			color = amountBasedColor(tonumber(status.wasteFilledPercentage))
		},
		{
			text = 'Coolant: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.coolant.amount / 1000, status.coolantCapacity, status.coolantFilledPercentage..'%'),
			color = amountBasedColor(tonumber(status.coolantFilledPercentage))
		},
		{
			text = 'Heated coolant: '
		},
		{
			text = string.format('%fB/%fB (%s)\n', status.heatedCoolant.amount / 1000, status.heatedCoolantCapacity, status.heatedCoolantFilledPercentage..'%'),
			color = amountBasedColor(tonumber(status.heatedCoolantFilledPercentage))
		},
		{
			text = 'Burn rate:' 
		},
		{
			text = string.format('%fmB/%fmB\n', status.burnRate, status.maxBurnRate),
			hoverEvent = {
				action = 'show_text',
				value = string.format('Actual to set burn rate: %f/%f (%s)', status.burnRate, status.actualBurnRate, status.actualToSetBurnRatePercentage..'%')
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

	local turbines = {}

	turbines.first = peripheral.wrap('turbineValve_0') or error('first turbine is not connected')
	turbines.second = peripheral.wrap('turbineValve_1') or error('second turbine is not connected')
	local chat = peripheral.find('chatBox') or error('chat box is not connected')

	require('components/configOperations')

	while chat ~= nil do
		local event, username, message, uuid, isHidden = os.pullEvent('chat')
		local config = configOperations.getFromFile() or error('unable to load configuration',1)
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