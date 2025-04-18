--!nocheck
--_scriptType="module"
--[[

                                                  
           ^J7~^.                                 
           G@@@@&#G5J7~^:                         
          !@@@@@@@@@@@@@&#G5J7!^:.                
          B@@@@@@@@@@@@@@@@@@@@@&#GPY?!^:.        
         7@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#BPY?!   
        .#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@5   
        ?@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&:   
       .&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Y    
       Y@@@@@@@@@@@@@@&&@@@@@@@@@@@@@@@@@@@@&:    
      :&@@@@@@@@@@@@@&^:~7J5P&@@@@@@@@@@@@@@J     
      5@@@@@@@@@@@@@@J      ^@@@@@@@@@@@@@@#.     
     ^@@@@@@@@@@@@@@#.      P@@@@@@@@@@@@@@?      
     P@@@@@@@@@@@@@@#5J7~^.!@@@@@@@@@@@@@@B       
    ~@@@@@@@@@@@@@@@@@@@@@&&@@@@@@@@@@@@@@7       
    G@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@G        
   !@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@!        
   B@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@P         
  .?Y5G#&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@~         
        :^!7J5G#&@@@@@@@@@@@@@@@@@@@@@@5          
                .^~7J5GB&@@@@@@@@@@@@@@^          
                        .^~7J5GB&@@@@@Y           
                                .:~7JY:           
                                                 

--]]

--[[
	( Update: 14.04.2025 )
	[+ PackageBase type]
	[+ DefinedNameSpaceClient type]
	[+ DefinedNameSpaceServer type]
	[~ DefinedNameSpace type]

	* @ Check out bytenet: https://devforum.roblox.com/t/bytenet-advanced-networking-library-w-buffer-serialization-strict-luau-absurd-optimization-and-rbxts-support-043/2733365
	    and documentation for it: https://ffrostfall.github.io/ByteNet/
	
	* @ Ough.. type checking...
	
	* @ i had to make that module for type checking functions,
	    so you can code easier ig.
	
	* @ made by @t10_kol
	
	Example:
	
	local ByteNetPackagesType = require(path.to.ByteNetPackagesType)
	
	local tbl = {} :: ByteNetPackagesType.TableType
	
	local Package_Server = {} :: ByteNetPackagesType.PackageServer
	local Package_Client = {} :: ByteNetPackagesType.PackageClient
	local Package_Base = {} :: ByteNetPackagesType.PackageBase
	
--]]
export type UnknownFunction = (any?|nil)->(any?|nil)
export type TableType = {[any]: any}
export type DataType = TableType?|any?

export type PackageBase = { -- Base functions in package
	getListeners:()->({[any]:(Data:DataType,Player:Player)->()}),
	reader:(buffer: buffer, cursor: number)->(any),
	wait:()->(UnknownFunction) -- coroutine.yield
}

export type PackageServer = PackageBase&{
	sendToAll:(Data:DataType)->(),
	sendToAllExcept:(Data:DataType,Player:Player)->(),
	sendTo:(Data:DataType,Player:Player)->(),
	sendToList:(Data:DataType,Players:{Player:Player})->(),
	listen:(func:(Data:DataType,Player:Player)->())->(),
}
export type PackageClient = PackageBase&{
	send:(Data:DataType)->(),
	listen:(func:(Data:DataType)->())->(),
}

--[[export type DefinedNameSpace = { -- you can make it non commentary and use it.. but i perfer DefinedNameSpaceClient and DefinedNameSpaceServer
	[any]:PackageBase&(PackageServer|PackageClient)
}]]

export type DefinedNameSpaceClient = {
	[any]:PackageClient
}
export type DefinedNameSpaceServer = {
	[any]:PackageServer
}

return {}
