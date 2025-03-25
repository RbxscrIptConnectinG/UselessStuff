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

	* @ Ough.. type checking...
	
	* @ i had to make that module for type checking functions,
	    so you can code easier ig.
	
	* @ made by @t10_kol
	
	Example:
	
	local ByteNetPackagesType = require(path.to.ByteNetPackagesType)
	
	type TableType = ByteNetPackagesType.TableType
	type PackageServer = ByteNetPackagesType.PackageServer
	type PackageClient = ByteNetPackagesType.PackageClient
	
	local cool_table : TableType = {}
	
	local Package_A1 : PackageServer = {}
	local Package_A2 : PackageClient = {}
	
--]]
export type UnknownFunction = (any?|nil)->(any?|nil)
export type TableType = {[any]: any}
export type DataType = TableType?|any?
export type PackageServer = {
	listen:(func:(Data:DataType,Player:Player)->())->(),
	sendToAll:(Data:DataType)->(),
	sendToAllExcept:(Data:DataType,Player:Player)->(),
	sendTo:(Data:DataType,Player:Player)->(),
	sendToList:(Data:DataType,Players:{Player:Player})->(),
	getListeners:()->({[any]:(Data:DataType,Player:Player)->()}),
	reader:(buffer: buffer, cursor: number)->(any),
	wait:()->(UnknownFunction) -- coroutine.yield
}
export type PackageClient = {
	listen:(func:(Data:DataType)->())->(),
	send:(Data:DataType)->(),
	getListeners:()->({[any]:(Data:DataType,Player:Player)->()}),
	reader:(buffer: buffer, cursor: number)->(any),
	wait:()->(UnknownFunction) -- coroutine.yield
}
export type DefinedNameSpace = {
	[any]:PackageServer?|PackageClient?|any?
}
return {}
