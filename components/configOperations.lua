local config = {}

-- sets config directly from the config.json
function config.getFromFile()
  local configFile = io.open('/scada/components/config.json','r')
  local jsonContents = configFile.readAll()
  configFile.close()

  return textutils.unserialiseJSON(jsonContents)
end

-- sets config directly to the config.json
function config.setToFile(configTable)
	local configFile = io.open('/scada/components/config.json','w')
	configFile.write(textutils.serialiseJSON(configTable))
	configFile.close()
end