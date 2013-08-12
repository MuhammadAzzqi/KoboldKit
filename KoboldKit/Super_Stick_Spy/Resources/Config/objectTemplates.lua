-- objectTemplates.lua
-- Defines names of objects in Tileds to determine which ObjC classes to create
-- and which properties/ivars to set on these classes.

local kContactCategoryWorld = 0
local kContactCategoryPlayer = 1
local kContactCategoryPickupItem = 2
local kContactCategoryTrigger = 4
local kContactCategoryStaticObject = 8

local kGameObjectCollisionBitMask = 0xffffffff - (kContactCategoryPickupItem + kContactCategoryTrigger)

local objectTemplates =
{
	-- Behavior templates are not actually nodes but one or more behaviors that can be added to a node in Tiled
	-- with the behavior's properties taken from Tiled's properties
	FollowPath =
	{
		{className = "KKFollowPathBehavior"}, -- physics contact resolves in a remove of this node
	},

	-- default node types and their class names
	Node = {className = "KKNode"},
	SpriteNode = {className = "KKSpriteNode", tiledColor = "#ffffff"},
	LabelNode = {className = "KKLabelNode"},
	EmitterNode = {className = "KKEmitterNode", initMethod = "emitterWithFile:", initParam = "emitterFile"},
	ContactNotificationNode = {className = "KKContactNotificationNode", tiledColor = "#ff00ff"},
	-- not yet supported
	ShapeNode = {className = "KKShapeNode"},
	VideoNode = {className = "KKAutoplayVideoNode"},
	
	Trigger =
	{
		inheritsFrom = "ContactNotificationNode",
		physicsBody =
		{
			properties = 
			{
				categoryBitMask = kContactCategoryTrigger,
				contactTestBitMask = kContactCategoryPlayer,
				dynamic = NO,
			},
		},
	},

	TriggerOnce =
	{
		inheritsFrom = "Trigger",
		properties =
		{
			onlyOnce = YES,
		},
	},
	
	Checkpoint =
	{
		inheritsFrom = "SpriteNode",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryTrigger,
				contactTestBitMask = kContactCategoryPlayer,
				dynamic = NO,
			},
		},
		behaviors =
		{
			{className = "KKNotifyOnContactBehavior", properties = {notification = "CheckpointActivated"}},
		},
	},
	
	Emitter =
	{
		inheritsFrom = "EmitterNode",
		emitterFile = "<missingfile.sks>",
	},
	
	Image =
	{
		inheritsFrom = "SpriteNode",
	},

	Text =
	{
		inheritsFrom = "LabelNode",
		properties =
		{
			fontName = "Arial",
			fontSize = 10,
			fontColor = {color = "1.0 0.0 1.0 1.0"}, -- color = "R G B A"
			text = "<missing text>",
		},
	},

	Player =
	{
		-- used by Tiled (needs simple tool to convert to Tiled objectdef.xml format)
		tiledColor = "#ff0055", 
		-- create an instance of this class (class must inherit from SKNode or its subclasses)
		className = "PlayerCharacter",
		
		properties =
		{
			_fallSpeedAcceleration = 50, -- how fast player accelerates when falling down
			_fallSpeedLimit = 300,			-- max falling speed
			_jumpAbortVelocity = 150,		-- the (max) upwards velocity forcibly set when jump is aborted
			_jumpSpeedInitial = 350,		-- how fast the player initially moves upwards when jumping is initiated
			_jumpSpeedDeceleration = 16,	-- how fast upwards motion (caused by jumping) decelerates
			_runSpeedAcceleration = 0,		-- how fast player accelerates sideways (0 = instant)
			_runSpeedDeceleration = 0,		-- how fast player decelerates sideways (0 = instant)
			_runSpeedLimit = 200,			-- max sideways running speed
			_boundingBox = "{12, 28}",
			--anchorPoint = "{0.5, 0.3}",

			_defaultImage = "dummy_stickman.png",
		},
		
		physicsBody =
		{
			properties =
			{
				allowsRotation = NO,
				mass = 0.33,
				restitution = 0.04,
				linearDamping = 0,
				angularDamping = 0,
				friction = 0,
				affectedByGravity = NO,
				categoryBitMask = kContactCategoryPlayer,
				contactTestBitMask = 0, --kContactCategoryPlayer + kContactCategoryPickupItem,
				collisionBitMask = kGameObjectCollisionBitMask,
			},
		},
		
		behaviors =
		{
			--{behaviorClass = "KKLimitVelocityBehavior", properties = {velocityLimit = 100}},
			{className = "KKStayInBoundsBehavior", properties = {bounds = "{{0, 0}, {0, 0}}"}},
			{className = "KKCameraFollowBehavior"},
			{className = "KKItemCollectorBehavior"},
			{className = "KKNotifyOnItemCountBehavior", properties = {itemName = "briefcase", count = 1, notification = "OpenLockedDoor1"}},
			{className = "KKNotifyOnItemCountBehavior", properties = {itemName = "briefcase", count = 2, notification = "OpenLockedDoor2"}},
			{className = "KKNotifyOnItemCountBehavior", properties = {itemName = "briefcase", count = 3, notification = "OpenLockedDoor3"}},
			{className = "KKNotifyOnItemCountBehavior", properties = {itemName = "briefcase", count = 4, notification = "OpenLockedDoor4"}},
			{className = "KKNotifyOnItemCountBehavior", properties = {itemName = "briefcase", count = 5, notification = "OpenLockedDoor5"}},
		},
		
		actions = 
		{
			-- not yet, coming soon
		},
	},

	PickupItem =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryPickupItem,
				contactTestBitMask = kContactCategoryPlayer,
				dynamic = NO,
			},
		},
		behaviors =
		{
			{className = "KKRemoveOnContactBehavior"}, -- physics contact resolves in a remove of this node
			{className = "KKPickupItemBehavior"},
		},
	},

	-- Game-Specific Items
	Briefcase =
	{
		inheritsFrom = "PickupItem",
		properties =
		{
			name = "briefcase",
			imageName = "dummy_case.png",
		},
	},
	
	ExitDoor =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0xffffffff,
				dynamic = NO,
			},
		},
		behaviors =
		{
			{className = "KKRemoveOnNotificationBehavior", properties = {notification = "OpenExitDoor"}},
		},
	},

	LockedDoor1 =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0xffffffff,
				dynamic = NO,				
			},
		},
		properties =
		{			
			imageName = "dummy_lockeddoor1.png",
		},
		behaviors =
		{
			{className = "KKRemoveOnNotificationBehavior", properties = {notification = "OpenLockedDoor1"}},
		},
	},

	LockedDoor2 =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0xffffffff,
				dynamic = NO,				
			},
		},
		properties =
		{			
			imageName = "dummy_lockeddoor2.png",
		},
		behaviors =
		{
			{className = "KKRemoveOnNotificationBehavior", properties = {notification = "OpenLockedDoor2"}},
		},
	},

	LockedDoor3 =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0xffffffff,
				dynamic = NO,				
			},
		},
		properties =
		{			
			imageName = "dummy_lockeddoor3.png",
		},
		behaviors =
		{
			{className = "KKRemoveOnNotificationBehavior", properties = {notification = "OpenLockedDoor3"}},
		},
	},

	LockedDoor4 =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0xffffffff,
				dynamic = NO,				
			},
		},
		properties =
		{			
			imageName = "dummy_lockeddoor4.png",
		},
		behaviors =
		{
			{className = "KKRemoveOnNotificationBehavior", properties = {notification = "OpenLockedDoor4"}},
		},
	},

	LockedDoor5 =
	{
		inheritsFrom = "Image",
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = 0xffffffff,
				dynamic = NO,				
			},
		},
		properties =
		{			
			imageName = "dummy_lockeddoor5.png",
		},
		behaviors =
		{
			{className = "KKRemoveOnNotificationBehavior", properties = {notification = "OpenLockedDoor5"}},
		},
	},

	Platform =
	{
		inheritsFrom = "Image",
			
		physicsBody =
		{
			properties =
			{
				categoryBitMask = kContactCategoryStaticObject,
				contactTestBitMask = kContactCategoryPlayer,
				collisionBitMask = kGameObjectCollisionBitMask,
				dynamic = YES,
				allowsRotation = NO,
				affectedByGravity = NO,
				mass = 265535,
				friction = 1,
				restitution = 0,
			},
		},
	},
}

return objectTemplates