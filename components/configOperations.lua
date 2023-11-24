local configOperations = {}

-- sets config directly from the config.json
function configOperations.getFromFile()
  local configFile = fs.open('/scada/components/config.json','r')
  local jsonContents = configFile.readAll()
  configFile.close()

  return textutils.unserialiseJSON(jsonContents)
end

-- sets config directly to the config.json
function configOperations.setToFile(configTable)
	local configFile = fs.open('/scada/components/config.json','w')
	configFile.write(textutils.serialiseJSON(configTable))
	configFile.close()
end

--return configOperations