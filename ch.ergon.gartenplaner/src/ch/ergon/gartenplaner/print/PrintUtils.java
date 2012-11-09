/*
 	PrintUtils.java

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

package ch.ergon.gartenplaner.print;

import java.awt.image.RenderedImage;
import java.awt.print.PrinterException;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.print.Doc;
import javax.print.DocFlavor;
import javax.print.DocPrintJob;
import javax.print.PrintException;
import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import javax.print.ServiceUI;
import javax.print.SimpleDoc;
import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.print.attribute.PrintRequestAttributeSet;
import javax.print.attribute.standard.Copies;

/**
 * Printing with choosing a printer dialog.
 * @author albin
 */
public class PrintUtils {
    public static void print(RenderedImage image) throws PrinterException, PrintException, IOException {
        DocFlavor docFlavor = DocFlavor.INPUT_STREAM.PNG;
        PrintRequestAttributeSet attributes = new HashPrintRequestAttributeSet();
        attributes.add(new Copies(1));
        PrintService printServices[] = PrintServiceLookup.lookupPrintServices(docFlavor, attributes);
        if (printServices.length == 0) {
            throw new RuntimeException("PrintService for PNG not available!");
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(image, "png", out);
        ByteArrayInputStream in = new ByteArrayInputStream(out.toByteArray());

        // print dialog, asking to which printer to print
        PrintService ps = ServiceUI.printDialog(null, 50, 50, printServices, null, docFlavor, attributes);
        if(ps != null) {
            // print it to the selected printservice
            DocPrintJob job = ps.createPrintJob();
            Doc doc = new SimpleDoc(in, docFlavor, null);
            job.print(doc, attributes);
            in.close();
        }
    }
}
