/*
 	GartenplanerConfirm.fx

 	Gartenplaner - A program to plan works in the garden.

 	Copyright (c) 2011 by Albin Meyer
 	albin.meyer@ergon.ch
 	http://www.ergon.ch/

 	This program is free software; you can redistribute it and/or modify
 	it under the terms of the GNU General Public License as published by
 	the Free Software Foundation; either version 2 of the License, or
 	(at your option) any later version.

 	This program is distributed in the hope that it will be useful,
 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 	GNU General Public License for more details.

 	You should have received a copy of the GNU General Public License
 	along with this program; If not, see <http://www.gnu.org/licenses/>.

 	Last updated: Jan 3, 2011
*/

package ch.ergon.gartenplaner.gui;
import javafx.animation.transition.ScaleTransition;
import javafx.scene.CustomNode;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.Container;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import ch.ergon.gartenplaner.entity.data.Bed;
import ch.ergon.gartenplaner.entity.data.PlantPlan;
import ch.ergon.gartenplaner.entity.data.ConcreteActivity;
import javafx.scene.layout.HBox;
import javafx.geometry.HPos;

public class GartenplanerConfirm extends CustomNode {
    public var callingScene : Scene;
    public var text : String;
    public var bed : Bed;
    public var plantPlan : PlantPlan;
    public var act : ConcreteActivity;
    public var yesFunc: function():Void;
    public var yesFuncDelPlantNut: function(:Bed, :PlantPlan):Void;
    public var yesFuncDelAct: function(:ConcreteActivity):Void;

    override function create() {
        return Container {
            layoutX: 400 // where the alert popup is located
            layoutY: 300 // where the alert popup is located

// javafx bug: following has no effect, mouse clicks are propagated to the underlying nodes like bed or plant
            blocksMouse : true; // so the mouseclick event is not propagated down to the bed rectangle

            content: [
                Rectangle {
                        stroke: Color.BLACK
                        strokeWidth: 1.5
                        arcWidth: 20
                        arcHeight: 20
                        height: 100
                        width: 280
                        fill: Color.WHEAT
                }

                VBox {
                    layoutX: 20 // relative to the container (The popup window)
                    layoutY: 10 // relative to the container (The popup window)
                    spacing: 20 // space between label and button
                    content: [
                        Label {
                            width: 240
                            textWrap: true
                            text: text
                        }
                        HBox {
                            hpos: HPos.CENTER
                            spacing: 40
                            content: [
                                Button {
                                    text: "Ja"
                                    action: function(): Void {
                                        delete confirmNode from confirmNode.callingScene.content;
                                        confirmNode = null;
                                        if(yesFunc != null) {
                                            yesFunc();
                                        } else if(yesFuncDelPlantNut != null) {
                                            yesFuncDelPlantNut(bed, plantPlan);
                                        } else if(yesFuncDelAct != null) {
                                            yesFuncDelAct(act);
                                        }


                                    }
                                }
                                Button {
                                    text: "Nein"
                                    action: function(): Void {
                                        delete confirmNode from confirmNode.callingScene.content;
                                        confirmNode = null;
                                    }
                                }
                            ]
                        }
                    ]
                }
            ]
        };

    }

}

package var confirmNode : GartenplanerConfirm = null;

/*
* popup the alert slowly scaling from very small to a good size.
*/
package var scaleOutTransition = ScaleTransition {
    duration: 1s
    node: bind confirmNode
    repeatCount: 1
    autoReverse: true
    fromX: 0.1
    fromY: 0.1
    toX: 1
    toY: 1
}

/*
* close any open alert popups. To be called by many locations,
* when something was clicked, where no such alert popup is desired.
*/
package function closeModalConfirmPopup(): Void {
    if(confirmNode != null) {
        delete confirmNode from confirmNode.callingScene.content;
        confirmNode = null;
    }
}

/*
* show a yes/no confirm popup. When yes is clicked, the function
* given through the parameter "yesFunc" will be called, without any params.
*/
package function showConfirm(msg : String, scene : Scene, yesFunc: function():Void): Void {
    if(confirmNode == null) {
       GartenplanerAlert.closeModalAlertPopup(); // workaround for javafx not providing a nice solution for closing already open popup        
       confirmNode = GartenplanerConfirm {
          text: msg
          callingScene: scene;
          yesFunc: yesFunc
       }
       insert confirmNode into scene.content;
       scaleOutTransition.playFromStart();
    }
}

/*
* show a yes/no confirm popup. When yes is clicked, the function
* given through the parameter "yesFunc" will be called, with
* the params bed and plantPlan.
* This is a workaround for JavaFX not providing a nice solution for modal popup windows.
*/
package function showConfirmDelPlantNut(msg : String, scene : Scene, yesFunc: function(:Bed, :PlantPlan):Void, bed: Bed, plantPlan : PlantPlan): Void {
    if(confirmNode == null) {
       GartenplanerAlert.closeModalAlertPopup(); // workaround for javafx not providing a nice solution for closing already open popup
       confirmNode = GartenplanerConfirm {
          text: msg
          callingScene: scene;
          yesFuncDelPlantNut: yesFunc
          bed: bed
          plantPlan: plantPlan
       }
       insert confirmNode into scene.content;
       scaleOutTransition.playFromStart();
    }
}

/*
* show a yes/no confirm popup. When yes is clicked, the function
* given through the parameter "yesFunc" will be called, with
* the param act.
* This is a workaround for JavaFX not providing a nice solution for modal popup windows.
*/
package function showConfirmDelActivity(msg : String, scene : Scene, yesFunc: function(:ConcreteActivity):Void, act: ConcreteActivity): Void {
    if(confirmNode == null) {
       GartenplanerAlert.closeModalAlertPopup(); // workaround for javafx not providing a nice solution for closing already open popup        
       confirmNode = GartenplanerConfirm {
          text: msg
          callingScene: scene;
          yesFuncDelAct: yesFunc
          act: act
       }
       insert confirmNode into scene.content;
       scaleOutTransition.playFromStart();
    }
}