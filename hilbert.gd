class_name Hilbert

extends Node2D

var x: int
var y: int
var stepx: int
var stepy: int
var level: int
var curve: Curve2D

func _init(x:int,y:int,level:int,direction:String="Up"):
	self.x=x
	self.y=y
	self.level=level
	self.direction=direction
	self.stepx=floor(x/(2*level))
	self.stepy=floor(y/(2*level))
	#Instructions for drawing the base shapes in each direction
	if(level==1):
		match self.direction:
			"Up":
				self.curve.add_point(Vector2(self.stepx,2*self.stepy))
				self.curve.add_point(Vector2(self.stepx,self.stepy))
				self.curve.add_point(Vector2(2*self.stepx,self.stepy))
				self.curve.add_point(Vector2(2*self.stepx,2*self.stepy))
			"Left":
				self.curve.add_point(Vector2(self.stepx,self.stepy))
				self.curve.add_point(Vector2(2*self.stepx,self.stepy))
				self.curve.add_point(Vector2(2*self.stepx,2*self.stepy))
				self.curve.add_point(Vector2(self.stepx,2*self.stepy))
			"Down":
				self.curve.add_point(Vector2(2*self.stepx,self.stepy))
				self.curve.add_point(Vector2(2*self.stepx,2*self.stepy))
				self.curve.add_point(Vector2(self.stepx,2*self.stepy))
				self.curve.add_point(Vector2(self.stepx,self.stepy))
			"Right":
				self.curve.add_point(Vector2(2*self.stepx,2*self.stepy))
				self.curve.add_point(Vector2(self.stepx,2*self.stepy))
				self.curve.add_point(Vector2(self.stepx,self.stepy))
				self.curve.add_point(Vector2(2*self.stepx,self.stepy))
	#Instructions for recursively adding combinations of base shapes
	else:
		match self.direction:
			"Up":
				_init(x/2,y/2,level-1,"Left")
				_init(x/2,y/2,level-1,"Up")
				_init(x/2,y/2,level-1,"Up")
				_init(x/2,y/2,level-1,"Right")
			"Left":
				_init(x/2,y/2,level-1,"Up")
				_init(x/2,y/2,level-1,"Left")
				_init(x/2,y/2,level-1,"Left")
				_init(x/2,y/2,level-1,"Down")
			"Down":
				_init(x/2,y/2,level-1,"Right")
				_init(x/2,y/2,level-1,"Down")
				_init(x/2,y/2,level-1,"Down")
				_init(x/2,y/2,level-1,"Left")
			"Right":
				_init(x/2,y/2,level-1,"Down")
				_init(x/2,y/2,level-1,"Right")
				_init(x/2,y/2,level-1,"Right")
				_init(x/2,y/2,level-1,"Up")
	pass
