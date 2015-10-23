﻿package {		// Internal imports	import flash.display.Bitmap;	import flash.display.DisplayObject;	import flash.display.Sprite;	import flash.display.StageAlign;	import flash.display.StageScaleMode;	import flash.events.Event;	import flash.events.MouseEvent;		// Nape imports	import nape.geom.Vec2;	import nape.phys.Body;	import nape.phys.BodyType;	import nape.phys.Material;	import nape.shape.Circle;	import nape.shape.Polygon;	import nape.space.Space;	import nape.util.Debug;	import nape.util.ShapeDebug;		public class NapePhysicsIntro extends Sprite {				/* To enable/disable our little debugging mode */		private const DEBUG:Boolean = true;				/* Reference to the Nape Physics space */		private var space:Space;				/* Reference to the floor physics body object */		private var floorPhysicsBody:Body;				/* Show shapes even if they don't have an attached DisplayObject (debug mode) */		private var debug:ShapeDebug;				/* Constructor */		public function NapePhysicsIntro() {						// Wait to be on stage before doing anything			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);		}				private function onAddedToStage(e:Event):void {						removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);						// Create the Nape space. This is where all the bodies in our physics			// world will reside. To create this world you need to pass in a Vec2			// object representing gravity. In this case, the first arg is the movement			// on the x axis and the second arg is the movement on the y axis.			space = new Space(new Vec2(0, 5000));						// Create a debugging object that will draw shape outlines (debug mode)			if (DEBUG) {				debug = new ShapeDebug(stage.stageWidth, stage.stageHeight);				addChild(debug.display);			}						// Create floor body (just below stage)			floorPhysicsBody = new Body(BodyType.STATIC);			var p:Polygon = new Polygon (											Polygon.rect(												0, 					// x position												stage.stageHeight, 	// y position												stage.stageWidth, 	// width												100					// height											)										);			floorPhysicsBody.shapes.add(p);			floorPhysicsBody.space = space;						stage.addEventListener(MouseEvent.MOUSE_DOWN, addBall);			addEventListener(Event.ENTER_FRAME, loop);					}						private function addBall(e:MouseEvent = null):void {						var s:Sprite = new Ball();			addChild(s);						// Create flag body and add it to the already-created space			var ballPhysicsBody:Body = new Body(				BodyType.DYNAMIC, new Vec2(Math.random() + stage.mouseX, stage.mouseY)			);			var material:Material = new Material(1.75);			ballPhysicsBody.shapes.add(new Circle(s.width >> 1, null, material));			ballPhysicsBody.space = space;						// Keep a reference to the visual assigned to that body			ballPhysicsBody.userData.graphic = s;					}				private function loop(e:Event):void {						// Clear the debug drawings before we go to the next frame 			if (DEBUG) debug.clear();						// Update the physics simulation and DisplayObjects positions			space.step(1 / stage.frameRate);			space.liveBodies.foreach(updateGraphics);						// Draw the debug drawing and commit pending operations			if (DEBUG) debug.draw(space);			if (DEBUG) debug.flush();						// Remove bodies and DisplayObjects that have moved offstage			for(var i:uint = 0; i < space.bodies.length; i++) {								// Get the current body in the loop				var b:Body = space.bodies.at(i);							// Do not delete the floor !				if (b == floorPhysicsBody) break;								// If the body is offstage, delete it along with the DisplayObject 				// assigned to it				if ( 					 (b.position.x > stage.stageWidth + b.userData.graphic.width) ||					 (b.position.x < -b.userData.graphic.width)					) {					b.userData.graphic.parent.removeChild(b.userData.graphic);					space.bodies.remove(b);									}			}					}				private function updateGraphics(b:Body):void {						// Grab a reference to the visual which we will update			var graphic:DisplayObject = b.userData.graphic;						// Update position of the graphic to match the simulation			graphic.x = b.position.x ;			graphic.y = b.position.y ;						// Update the rotation of the graphic. Note: AS3 uses degrees to express rotation 			// while Nape uses radians. Also, the modulo (%360) has been put in because AS3 			// does not like big numbers for rotation (so I've read).			graphic.rotation = (b.rotation * 180 / Math.PI) //% 360;		}			}	}