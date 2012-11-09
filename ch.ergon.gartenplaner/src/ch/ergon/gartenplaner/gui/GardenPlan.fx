/*
 	GardenPlan.fx

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

import ch.ergon.gartenplaner.entity.data.Garden;
import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
import javafx.scene.Node;
import javafx.scene.Group;
import javafx.scene.control.Button;
import com.javafx.preview.layout.Grid;
import ch.ergon.gartenplaner.entity.data.Bed;
import com.javafx.preview.layout.GridRow;
import ch.ergon.gartenplaner.entity.data.PlantPlan;
import javafx.scene.control.Label;
import javafx.scene.image.ImageView;
import javafx.scene.image.Image;
import ch.ergon.gartenplaner.entity.DatabaseManager;
import ch.ergon.gartenplaner.entity.data.ConcreteActivity;
import javafx.stage.Alert;
import ch.ergon.gartenplaner.entity.data.BedHasGroundCharacteristic;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.Scene;
import javafx.scene.control.ScrollView;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;
import javafx.scene.control.Tooltip;
import javafx.scene.layout.Panel;
import java.lang.Error;
import java.lang.RuntimeException;
import ch.ergon.gartenplaner.print.PrintFxUtils;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.animation.transition.FadeTransition;
import javafx.scene.control.TextBox;


/**
 * Gartenplan Mask.
 * @author albin
 */

 // the current garden
package var garden: Garden = bind LoadGarden.selectedGarden.garden;

package var currentMonth = garden.getCurrentMonth();
package var currentYear = garden.getCurrentYear();
package var planningYear = garden.getCurrentYear();

// the grid at the bottom with the planned plants of the currently selected bed
var bedPlanGrid : Grid = Grid {
    rows: drawPlanGridRows(null)
}

var gardenPlanGroup : Group = Group {
    content: drawGardenPlan()
}

// the currently selected bed
public var currentBed: Bed = bind BedRectangle.currentBed on replace {
   refreshPlanGrid();
}

var nutrientOfCurrentBed: VBox = VBox {
    content: bind drawNutrientsOfCurrentBed(currentBed);
}

function drawNutrientsOfCurrentBed(bed : Bed) : Node[] {
    try {
        var retVal : Node[];
        insert Label {
            text: "Bodenbeschaffenheit\ndes selektierten Beets:"
            styleClass: "gardenPlaner"
        } into retVal;
        if(bed != null and bed.getGroundCharList() != null) {
            var gcList = bed.getGroundCharList();
            for(gc : BedHasGroundCharacteristic in gcList) {
                var changedMuchText : String;
                if(gc.getChangedMuch()) {
                    changedMuchText = "Änderte sich mehr als 20% zum Vorjahr."
                } else {
                    changedMuchText = "Änderte sich weniger als 20% zum Vorjahr."
                }
                var textColor : Color;
                if(gc.getAmount() < 40 or gc.getAmount() > 60) {
                    textColor = Color.RED;
                } else {
                    textColor = Color.GREEN;
                }

                var tooltip = Tooltip {
                    // showing a description of a ground characterstic in the mask,
                    // explaining exactly, what 0% and 100% mean
                    text: "{gc.getGroundCharacteristic().getDescription()}\n{changedMuchText}";
                }
                insert HBox {
                    content: [
                        Button {
                            text: "++" // increase the amount of this nutrient in this bed
                            action: function() {
                                gc.setAmount(gc.getAmount() + 1);
                                DatabaseManager.saveBedGroundCharacteristic(gc);
                                drawNutrientsOfCurrentBed(currentBed);

                                // workaround to get the nutrient values refreshed: change currentbed and reset to original version for get binding done
                                var currBed : Bed = BedRectangle.currentBed;
                                BedRectangle.currentBed = null;
                                BedRectangle.currentBed = currBed;
                            }
                        }
                        Button {
                            text: "--" // decrease the amount of this nutrient in this bed
                            action: function() {
                                gc.setAmount(gc.getAmount() - 1);
                                DatabaseManager.saveBedGroundCharacteristic(gc);
                                drawNutrientsOfCurrentBed(currentBed);

                                // workaround to get the nutrient values refreshed: change currentbed and reset to original version for get binding done
                                var currBed : Bed = BedRectangle.currentBed;
                                BedRectangle.currentBed = null;
                                BedRectangle.currentBed = currBed;
                            }
                        }
                        Label {
                            text: "{gc.getGroundCharacteristic().getName()}: {gc.getAmount()}%";
                            styleClass: "gardenPlaner"
                            textFill: textColor
                            onMouseEntered: function(e): Void {
                                tooltip.activate();
                            }
                            onMouseExited: function(e): Void {
                                tooltip.deactivate();
                            }
                        }
                        tooltip
                    ]
                } into retVal;
            }
        }
        return retVal;
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
     return null;
}


package function refreshPlanGrid() : Void {
    // assigning a whole grid on each refresh is a workaround to get the scrollview working, where this grid resides in
    // actually I expected following code to be good enough, but it isn't:  bedPlanGrid.rows = drawPlanGridRows(currentBed);
    // so as a workaround I had to write following code, together with binding the content of the scrollview to bedPlanGrid
    bedPlanGrid = Grid {
        rows: drawPlanGridRows(currentBed)
    }

    // This is a workaround for JavaFX not providing a nice solution for modal popup windows.
    GartenplanerAlert.closeModalAlertPopup();
    GartenplanerConfirm.closeModalConfirmPopup();
}

public function refreshAll() : Void {
    refreshBedAndGrid();
    currentMonth = garden.getCurrentMonth();
    currentYear = garden.getCurrentYear();
    planningYear = garden.getCurrentYear();
}


// refresh the beds and the planned plants view (e.g. when coming back from plant-choice mask or button naechster monat)
public function refreshBedAndGrid() : Void {
    try {
        refreshPlanGrid();
        gardenPlanGroup.content = drawGardenPlan();

        // workaround to get the nutrient values refreshed: change currentbed and reset to original version for get binding done
        var currBed : Bed = BedRectangle.currentBed;
        BedRectangle.currentBed = null;
        BedRectangle.currentBed = currBed;
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
}

// draw the beds
function drawGardenPlan(): Node[] {
    try {
        var nodeArray : Node[];

        // first draw the border of the whole garden
        insert Rectangle {
            height: GartenplanerConstants.GARDEN_LAYOUT_HEIGHT
            width: GartenplanerConstants.GARDEN_LAYOUT_WIDTH
//            fill: Color.rgb(125, 180, 100) // a nice light green.
            fill: Color.rgb(40, 80, 30) // browngreen background color
        } into nodeArray;

        // now drawing all the beds inside the garden
        for(bed in garden.getBedList()) {
            insert BedRectangle {
                bed: bed
            } into nodeArray;
        }
        return nodeArray;
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
     return null;
}


// get activity that can be deleted in the plant plan grid
package function getDeletableActivity(act:ConcreteActivity, x:Integer, y:Integer) : ImageView {
    //TODO get tooltip working for activity deletable in plant plan grid
    // wanted to introduce tooltip for deletable activity, but then I get the layout not well done on the plant plan calendar grid
    // neither when packaging Imageview plus tooltip in a group nor in a panel.
    // so I do without tooltip
    ImageView {
        x: x;
        y: y;
        blocksMouse : true; // so the mouseclick event is not propagated down to the bed rectangle
        onMouseClicked: function(e): Void {
            if(currentYear > act.getPlantPlan().getYear()
                or currentYear == act.getPlantPlan().getYear() and currentMonth > act.getMonth()) {
                GartenplanerAlert.showAlert("Kann Aktivität der Vergangenheit nicht löschen!", scene);
                return; //ignore the click, because activity is in past
            }
            GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
            GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
            GartenplanerConfirm.showConfirmDelActivity("Wollen Sie diese Aktivität wirklich löschen?", scene, deleteActivity, act);
        }
        image: if(act.isDone()) {
                    Image {
                        url: "{__DIR__}{act.getName()}_DONE.jpg"
                        height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                        width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                    }
                } else {
                    Image {
                        url: "{__DIR__}{act.getName()}.jpg"
                        height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                        width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                    }
                }
    }
}

// get activity that can be clicked as done/not done in the bed
package function getDonableActivity(act:ConcreteActivity, x:Integer, y:Integer) : Panel {
    try {
        var panel : Panel;
        var tooltip = Tooltip {
                    text: "Klicken Sie auf das Aktivitätsbild, um es als erledigt/nicht erledigt zu markieren."
                }
        panel = Panel {
            content: [
                Rectangle {
                    // the border of the activity inmage in the bed
                    stroke: Color.ORANGE
                    strokeWidth: 3
                    arcWidth: 5
                    arcHeight: 5
                    x: x
                    y: y
                    height: GartenplanerConstants.ACTIVITY_PIC_INBED_HEIGHT
                    width: GartenplanerConstants.ACTIVITY_PIC_INBED_WIDTH
                }

                ImageView {
                    x: x;
                    y: y;
                    onMouseEntered: function(e): Void {
                        tooltip.activate();
                    }
                    onMouseExited: function(e): Void {
                        tooltip.deactivate();
                    }
                    blocksMouse : true; // so the mouseclick event is not propagated down to the bed rectangle
                    onMouseClicked: function(e): Void {
                        var imgView = e.source as ImageView;
                        act.toggleDoneStatus();
                        DatabaseManager.saveConcreteActivity(act);

                        // explicitely set the correct image in the bed
                        if(act.isDone()) {
                            imgView.image= Image {
                                url: "{__DIR__}{act.getName()}_DONE.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_INBED_HEIGHT
                                width: GartenplanerConstants.ACTIVITY_PIC_INBED_WIDTH
                            }
                        } else {
                            imgView.image= Image {
                                url: "{__DIR__}{act.getName()}.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_INBED_HEIGHT
                                width: GartenplanerConstants.ACTIVITY_PIC_INBED_WIDTH
                            }
                        }

                        refreshPlanGrid(); // refresh the plan grid only, but not the bed because done-clicks are made in the beds

                        // actually I tried to bind the image url to the member var of the ConcreteActivity, like tying the view to the model, but this does not work

                    }
                    image: if(act.isDone()) {
                                Image {
                                    url: "{__DIR__}{act.getName()}_DONE.jpg"
                                    height: GartenplanerConstants.ACTIVITY_PIC_INBED_HEIGHT
                                    width: GartenplanerConstants.ACTIVITY_PIC_INBED_WIDTH
                                }
                            } else {
                                Image {
                                    url: "{__DIR__}{act.getName()}.jpg"
                                    height: GartenplanerConstants.ACTIVITY_PIC_INBED_HEIGHT
                                    width: GartenplanerConstants.ACTIVITY_PIC_INBED_WIDTH
                                }
                            }
                }
                tooltip
             ]
          };
          return panel;
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
     return null;
}

// draw the grid rows of the planned plant view
function drawPlanGridRows(bed: Bed): GridRow[] {
    try {
        var gridRows : GridRow[];
        insert
            GridRow {
                cells: [
                    Label {
                        layoutInfo: LayoutInfo {minWidth: 120 width: 120 maxWidth: 120 } // defining a constant width of this cell
                        text: "Pflanze"
                        styleClass: "gardenPlanerBlack"
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Jan"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 1 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Feb"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 2 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Mar"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 3 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Apr"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 4 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Mai"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 5 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Jun"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 6 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Jul"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 7 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Aug"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 8 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Sep"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 9 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Okt"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 10 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Nov"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 11 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH width: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH maxWidth: GartenplanerConstants.CALENDAR_GRIDROW_WIDTH } // defining a constant width of this cell
                        text: "Dez"
                        styleClass: "gardenPlanerBlack"
                        textFill: if(bed.getGarden().getCurrentMonth() == 12 and currentYear == planningYear ) { Color.AQUA } else { Color.BLACK }
                    }
                    Label {
                        layoutInfo: LayoutInfo {minWidth: 160 width: 160 maxWidth: 160 } // defining a constant width of this cell
                        text: "Aktion"
                        styleClass: "gardenPlanerBlack"
                    }
                ]
            } into gridRows;
        if(bed != null) {
            for(plantPlan : PlantPlan in bed.getPlantPlanList(planningYear)) {
                // first define and assign a grid row element array
                var gridRowEl : Node[];
                // the name of the plant
                insert Label {
                           layoutInfo: LayoutInfo {width: 120} // width directly on Label does not work
                           text: plantPlan.getName()
                           styleClass: "gardenPlanerBlack"
                       } into gridRowEl;
                // now filling the 12 months activities for this plant of this bed
                for(i in [1..12]) {
                    var color : Number;
                    // calculate, whether this column month is in the past, present or future
                    if(bed.getGarden().getCurrentMonth() < i and planningYear == bed.getGarden().getCurrentYear()
                        or planningYear > bed.getGarden().getCurrentYear()) {
                        color = PlantPlanGridTextNode.FUTURE
                    } else if(bed.getGarden().getCurrentMonth() == i and planningYear == bed.getGarden().getCurrentYear()) {
                        color = PlantPlanGridTextNode.PRESENT
                    } else {
                        color = PlantPlanGridTextNode.PAST
                    }

                    var act = plantPlan.getConcreteActivity(i);
                    if(act != null) {
                        // there is an activity this month, so show the picture from the filesystem
                        var imgView : ImageView = getDeletableActivity(act, 0, 0);
                        insert PlantPlanGridActivityNode {
                                concreteActivity: act
                                activityImage: imgView
                                backgroundColor: color // depending on month is in past, present or future
                            } into gridRowEl;
                    } else {
                        // there is no activity this month, so show a dash
                        insert PlantPlanGridTextNode {
                                text: "-"
                                backgroundColor: color // depending on month is in past, present or future
                            } into gridRowEl;
                    }
                }
                var loeschButtonText = "Lösche Pflanze";
                if(plantPlan.getFertilizer() != null) {
                    loeschButtonText = "Lösche Düngung";
                }
                insert Button {
                    layoutInfo: LayoutInfo {minWidth: 140 width: 140 maxWidth: 140} // width directly does not work
                    text: loeschButtonText
                    disable: planningYear < currentYear
                    action: function() {
                        GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                        GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                        GartenplanerConfirm.showConfirmDelPlantNut("Wollen Sie die in diesem Beet geplante Pflanze oder Düngung wirklich löschen?", scene, deletePlantOrNutr, bed, plantPlan);
                    }
                } into gridRowEl;

                // now insert this grid row elements to the gridrow
                insert GridRow {
                        cells: [
                            gridRowEl
                        ]
                    } into gridRows;
            }
         }
         return gridRows;
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
     return null;
}

// the input field for the bed name on the calendar
var bedNameInputField : TextBox = TextBox {
    promptText: bind currentBed.getName(planningYear)
    editable: bind currentBed != null and planningYear >= currentYear // only edit the bed name if a bed is selected and planning is not past
    action: function(): Void {
        var bedName : String = bedNameInputField.text;
        currentBed.setName(planningYear, bedName);
        DatabaseManager.saveBed(currentBed);

        refreshBedAndGrid(); // so the bedname is immediately displayed in the bed

        bedNameInputField.text = null; // workaround javafx: otherwise the inpufield won't get refreshed when clicking another bed
        planningYear ++; planningYear --; //workaround javafx: otherwise the inputfield won't keep the new inserted name
  }
}

package var sceneNode : Node = HBox {
        content: [
            VBox {
                content: [
                    gardenPlanGroup,
                    HBox {
                        content: [
                            VBox {
                                content: [
                                    Label {
                                        text: "Kalender für das selektierte Beet:"
                                        styleClass: "gardenPlaner"
                                    }
                                    HBox {
                                        content: [
                                            Button {
                                                text: "<"
                                                action: function() {
                                                    planningYear--;
                                                    refreshPlanGrid();
                                                }
                                            }
                                            Label {
                                                text: bind "{planningYear}";
                                                styleClass: "gardenPlanerYear"
                                            }
                                            Button {
                                                text: ">"
                                                action: function() {
                                                    planningYear++;
                                                    refreshPlanGrid();
                                                }
                                            }
                                            Button {
                                                text: "Neue Pflanze im Beet planen"
                                                disable: planningYear < currentYear
                                                action: function() {
                                                    GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                                                    GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                                    if(currentBed == null) {
                                                        GartenplanerAlert.showAlert("Kein Beet selektiert.", scene);
                                                    } else if(planningYear < currentYear) {
                                                        GartenplanerAlert.showAlert("Vergangenheit ist nicht planbar.", scene);
                                                    } else {
                                                        // workaround to refresh plant list in plant choice mask: change bound variable and back to orig value
                                                        ChoosePlant.guteNachbarn = not ChoosePlant.guteNachbarn;
                                                        ChoosePlant.guteNachbarn = not ChoosePlant.guteNachbarn;

//                                                        ChoosePlant.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
                                                        scene.stage.scene = ChoosePlant.scene;
                                                    }
                                                }
                                            }
                                            Button {
                                                text: "Neue Düngung im Beet planen"
                                                disable: planningYear < currentYear
                                                action: function() {
                                                    GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                                                    GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                                    if(currentBed == null) {
                                                        GartenplanerAlert.showAlert("Kein Beet selektiert.", scene);
                                                    } else if(planningYear < currentYear) {
                                                        GartenplanerAlert.showAlert("Vergangenheit ist nicht planbar.", scene);
                                                    } else {
                                                        // workaround to refresh plant list in plant choice mask: change bound variable and back to orig value
                                                        ChooseFertilizer.gute = not ChooseFertilizer.gute;
                                                        ChooseFertilizer.gute = not ChooseFertilizer.gute;

//                                                      ChooseFertilizer.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
                                                        scene.stage.scene = ChooseFertilizer.scene;
                                                    }
                                                }
                                            }
                                            Label {
                                                text: " Diesjähriger Name des Beets: "
                                                styleClass: "gardenPlaner"
                                            }
                                            bedNameInputField
                                        ]
                                    }
                                    ScrollView {
                                        layoutInfo: LayoutInfo {minHeight: 220 height: 220 maxHeight: 220 minWidth: 800 width: 800 maxWidth: 800} // fixed size scrollview for plant plan grid
                                        fitToWidth: true
                                        node: bind bedPlanGrid   // binding to grid is a workaround for correctly displaying a grid inside a scrollview, together with reassigning grid on each change
                                    }
                                ]
                            }
                        ]
                    }
                 ]
              }
            VBox {
                content: [
                    Label {
                        text: bind "Aktueller Monat: {currentMonth}.{currentYear}"
                        textFill: Color.AQUA
                        styleClass: "gardenPlaner"
                    }
                    Button {
                        text: "Nächster Monat"
                        action: function() {
                            try {
                                GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                                GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                if(garden.allPlannedActivitiesDoneThisMonth()) {
                                    // go to next month, persist the updated current date
                                    GartenplanerConfirm.showConfirm("Möchten Sie wirklich zum nächsten Monat schreiten? Ist wirklich wieder ein Monat vorbei?", scene, yesNextMonth);
                                } else {
                                    GartenplanerAlert.showAlert("Noch nicht alle Aktivitäten dieses Monats erledigt.", scene);
                                }
                             } catch (t: RuntimeException){
                                Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
                             } catch (t: Error){
                                Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
                             } // cannot catch Throwable, because javafx often throws NonLocalReturnException
                        }
                    }
                    Label { // gap (Workaround, how else could I paint a gap?)
                        text: ""
                    }
                    nutrientOfCurrentBed,
                    Label { // gap (Workaround, how else could I paint a gap?)
                        text: ""
                    }
                    HBox {
                        content: [
                                Button {
                                    text: "Tipps"
                                    action: function() {
                                        GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                                        GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                        Tipps.refresh(); // workaround on init a new gui
                                        scene.stage.scene = Tipps.scene;
                                    }
                                }
                                Button {
                                    text: "Drucken"
                                    action: function() {
                                        GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                                        GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                        PrintFxUtils.printScene();
                                    }
                                }
                                Button {
                                    text: "Beenden"
                                    action: function() {
                                        GartenplanerConfirm.closeModalConfirmPopup(); // workaround to javafx not providing nice popup solution
                                        GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                        GartenplanerConfirm.showConfirm("Wollen Sie wirklich beenden?", scene, quitToEntrance);
                                    }
                                }
                            ]
                    }
                    VBox {
                        content: [
                            Label {
                                styleClass: "gardenPlanerSmall"
                                text: "Um eine neue Pflanze oder Düngung\neines Beetes zu planen, klicken\nSie zuerst das Beet an, danach\nden entsprechenden Knopf im\nKalender."
                            }
                            Label {
                                styleClass: "gardenPlanerSmall"
                                text: "Um eine geplante Aktivität zu\nlöschen, klicken Sie auf das\nAktivitäts-Bild im Kalender."
                            }
                            Label {
                                styleClass: "gardenPlanerSmall"
                                text: "Um eine Aktivität als erledigt zu\nmarkieren, klicken Sie auf das\nAktivitäts-Bild im Beet."
                            }
                            Label {
                                styleClass: "gardenPlanerSmall"
                                text: "Um die Bodenbeschaffenheit zu\nbeschreiben, klicken Sie auf die\nentsprechenden ++/-- Knöpfe."
                            }
                            Label {
                                styleClass: "gardenPlanerSmall"
                                text: "Um die Lösung eines Problems\nzu lesen, klicken Sie auf die\nentsprechende Pflanze im Beet."
                            }
                        ]
                    }
                 ]
            }
        ]
    }



package var scene: Scene = Scene {
        width: GartenplanerConstants.SCENE_WIDTH
        height: GartenplanerConstants.SCENE_HEIGHT
        stylesheets: [ "{__DIR__}GartenPlaner.css" ]
        fill: Color.BLACK        
        content: [
                sceneNode
            ]
}

// calling fadeintransition.playFromStart() will slowly fade in this mask
// but: it does not work properly, when using this at mask change when assigning a new scene to the stage.
// it then flickers sometimes the gui, before starting the fade with black
package var fadeintransition = FadeTransition {
    duration: 2s
    node: sceneNode
    repeatCount: 1
    autoReverse: true
    fromValue: 0.0
    toValue: 10.0
}

/*
* callback function for yes/no popup.
*/
function quitToEntrance() : Void {
    scene.stage.scene = Entrance.scene;
}

/*
* callback function for yes/no popup.
*/
function deletePlantOrNutr(bed: Bed, plantPlan: PlantPlan) : Void {
    bed.removePlantPlan(plantPlan);
    DatabaseManager.deletePlantPlan(plantPlan);
    refreshBedAndGrid();
}

/*
* callback function for yes/no popup.
*/
function deleteActivity(act: ConcreteActivity) : Void {
    DatabaseManager.deleteConcreteActivity(act);
    refreshBedAndGrid(); // refresh beds and plant plan
}

/**
* callback function for yes/no next month
*/
function yesNextMonth() : Void {
    garden.nextMonth();
    currentYear = garden.getCurrentYear();
    currentMonth = garden.getCurrentMonth();
    DatabaseManager.saveGarden(garden);
    refreshBedAndGrid();
}
