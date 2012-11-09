/*
 	Problems.fx

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

import javafx.scene.Scene;
import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.layout.LayoutInfo;
import ch.ergon.gartenplaner.entity.def.DefPlant;
import javafx.scene.control.Button;
import javafx.scene.paint.Color;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import ch.ergon.gartenplaner.entity.def.DefProblem;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.layout.Panel;
import javafx.scene.shape.Rectangle;
import javafx.scene.Node;
import javafx.animation.transition.FadeTransition;


/**
 * Problems mask of a plant.
 * @author albin
 */

package var plant : DefPlant;

package class ProblemListViewItem {
    package var problem: DefProblem;
    public override function toString() {
        // the string to be displayed in the choice list in the mask
        problem.getName();
    }
}

package function loadProblemList() : ProblemListViewItem[] {
    var col  = plant.getProblemList();
    listView.clearSelection(); // so selectedPlant gets null
    visibleDesc = false;
    for(p in col) {
        ProblemListViewItem {
            problem: p
        }
    }
}

package function refresh() {
    problemList = loadProblemList();
}

package var problemList;

var listView : ListView = ListView {
    items: bind problemList;
    vertical: true;
    layoutInfo: LayoutInfo {
        vfill: false;
        height: 400;
        width: 300;
    }
}

package var selectedProblem: ProblemListViewItem = bind listView.selectedItem as ProblemListViewItem on replace {
        visibleDesc = true;
        problemImage = Image {
                        url: "{__DIR__}{selectedProblem.problem.getPicFileName()}"
                        height: 80
                        width: 80
                    }
    };
package var visibleDesc = false; // workaround to javafx not redrawing description label when updating plantlist after checkbox change
package var problemImage : Image;

package var sceneNode: Node = VBox {
                layoutX: 100
                layoutY: 20
                content: [
                    Label {
                        text: bind "Wählen Sie ein Problem aus\nbetreffend {plant.getName()}";
                        styleClass: "gardenPlanerBlack"
                    }
                    HBox {
                        spacing: 20
                        content: [
                            VBox {
                                content: [
                                    listView
                                ]
                            }
                            Panel {
                                content: [
                                    Rectangle {
                                        // the border of the problem image
                                        stroke: Color.ORANGE
                                        strokeWidth: 3
                                        arcWidth: 5
                                        arcHeight: 5
                                        y: 0
                                        height: 80
                                        width: 80
                                    }
                                    ImageView {
                                        image: bind problemImage;
                                    }
                                 ]
                            }
                            Label {
                                text: bind if (selectedProblem == null) then "-" else selectedProblem.problem.getDescription();
                                visible: bind visibleDesc; // workaround javafx bug not binding selectedPlant correctly to the text of this label
                                textWrap: true
                                width: 300
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Button {
                                text: "Zurück"
                                action: function() {
                                    // go back to garden plan without doing anything
//                                    GardenPlan.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
                                    scene.stage.scene = GardenPlan.scene;
                                }
                            }
                        ]
                    }
                ]
            }


package var scene: Scene = Scene {
        width: GartenplanerConstants.SCENE_WIDTH
        height: GartenplanerConstants.SCENE_HEIGHT
        fill: Color.rgb(125, 180, 100) // a nice light green. wanted black, but checkboxes don't work with stylesheets, so no white text possible
        stylesheets: [ "{__DIR__}GartenPlaner.css" ]
        content: [
            sceneNode
        ]
}

package var fadeintransition = FadeTransition {
    duration: 2s
    node: sceneNode
    repeatCount: 1
    autoReverse: true
    fromValue: 0.0
    toValue: 10.0
}