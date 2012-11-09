/*
 	Alert.fx

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

import javafx.scene.layout.Container;
import javafx.scene.CustomNode;
import javafx.scene.control.Button;
import javafx.animation.transition.ScaleTransition;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.VBox;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;
import javafx.geometry.HPos;
import javafx.scene.layout.HBox;

public class GartenplanerAlert extends CustomNode {
    public var callingScene : Scene;
    public var text : String;

    override function create() {
        return Container {
            layoutX: 400 // where the alert popup is located inside the scene
            layoutY: 300 // where the alert popup is located inside the scene
            
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
                            content: [
                                Button {
                                    text: "Ok"
                                    action: function(): Void {
                                        delete GartenplanerAlert.alertNode from GartenplanerAlert.alertNode.callingScene.content;
                                        GartenplanerAlert.alertNode = null;
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

package var alertNode : GartenplanerAlert = null;

/*
* popup the alert slowly scaling from very small to a good size.
*/
package var scaleOutTransition = ScaleTransition {
    duration: 1s
    node: bind alertNode
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
package function closeModalAlertPopup(): Void {
    if(GartenplanerAlert.alertNode != null) {
        delete GartenplanerAlert.alertNode from GartenplanerAlert.alertNode.callingScene.content;
        GartenplanerAlert.alertNode = null;
    }
}

/*
* popup an alert. Will be closed either when clicking ok, or when
* closeModalAlertPopup() is called.
*/
package function showAlert(msg : String, scene : Scene): Void {
    if(GartenplanerAlert.alertNode == null) {
       GartenplanerConfirm.closeModalConfirmPopup(); // workaround for javafx not providing a nice solution for closing already open popup
       GartenplanerAlert.alertNode = GartenplanerAlert {
          text: msg
          callingScene: scene;
       }
       insert GartenplanerAlert.alertNode into scene.content;
       GartenplanerAlert.scaleOutTransition.playFromStart();
    }
}
