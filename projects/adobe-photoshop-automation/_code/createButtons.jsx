/******************************************************************************
*
* createButton 1.0
*
* Created By: John Paul Newman
*
* Description: Photoshop script to create buttons.
*
******************************************************************************/

var insertHitRect = true;	// Insert a blank hit rect as the first element.
var maxHitRectSize = true;	// If true make the hit rect the maximum button width and height. If false use the minimum button default, over, under size.

var compressButtonWidths = false;	// If true packs the button image tightly.
var horizontalStrip = true;	// if true create a horizontal button strip, if false create a vertical stack of buttons.

var includeVisibleLayers = false;	// If true visible layers are processed, otherwise they are ignored.
var includeNestedButtons = true;	// If true nested buttons are included, otherwise they are ignored.

/*****************************************************************************/

function clsButton()
{
	this.btnLayerSet = null;

	this.arrHitStateLayersIdx = [];
	this.arrUpStateLayersIdx = [];
	this.arrOverStateLayersIdx = [];
	this.arrDownStateLayersIdx = [];

	this.arrNestedButtonsIdx = [];
}

/*****************************************************************************/

function findButtonLayerSets(parentObject, arrButtons)
{
	var layers = parentObject.layers;

	for (var layerIdx = 1; layerIdx <= layers.length; layerIdx++)
	{
		var curLayer = layers[layerIdx - 1];

		if (curLayer.typename == "LayerSet")
		{
			if ( (curLayer.visible == true) || (includeVisibleLayers == true) )
			{
				var btnMatch = (curLayer.name.search(/^btn_/i) != -1);

				if (btnMatch == true)
				{
					var clsBtn = new clsButton();

					findButtonStates(curLayer, clsBtn);

					arrButtons.push(clsBtn);
				}

				if ( (btnMatch == false) || (includeNestedButtons == true) )
				{
					findButtonLayerSets(curLayer, arrButtons);
				}
			}
		}
	}
}
/*****************************************************************************/

function findButtonStates(curBtnLayerSet, clsBtn)
{
	clsBtn.btnLayerSet = curBtnLayerSet;

	var layers = clsBtn.btnLayerSet.layers;

	for (var layerIdx = 1; layerIdx <= layers.length; layerIdx++)
	{
		var anIdx = layerIdx - 1;
		var curLayer = layers[anIdx];

		if ( (curLayer.visible == true) || (includeVisibleLayers == true) )
		{
			if (curLayer.name.search(/\[HIT\]/i) != -1)
			{
				clsBtn.arrHitStateLayersIdx.push(anIdx);
			}

			if (curLayer.name.search(/\[UP\]/i) != -1)
			{
				clsBtn.arrUpStateLayersIdx.push(anIdx);
			}

			if (curLayer.name.search(/\[OVER\]/i) != -1)
			{
				clsBtn.arrOverStateLayersIdx.push(anIdx);
			}

			if (curLayer.name.search(/\[DOWN\]/i) != -1)
			{
				clsBtn.arrDownStateLayersIdx.push(anIdx);
			}
		}

		if ( (curLayer.typename == "LayerSet") && (curLayer.name.search(/^btn_/i) != -1) )
		{
			clsBtn.arrNestedButtonsIdx.push(anIdx);
		}
	}
}
/*****************************************************************************/

function createButtons(theDoc, arrButtons)
{
	var numOfCells = insertHitRect ? 4 : 3;

	var multiplyWidthBy = numOfCells;
	var multiplyHeightBy = 1;

	if (horizontalStrip == false)
	{
		multiplyWidthBy = 1;
		multiplyHeightBy = numOfCells;
	}

	for (var layerIdx in arrButtons)
	{
		var clsBtn = arrButtons[layerIdx];

		if (clsBtn.btnLayerSet == null)
		{
			alert("ERROR: Button LayerSet not defined!!! N.B. This maybe a script error.");
			return;
		}

		var x1 = clsBtn.btnLayerSet.bounds[0];
		var y1 = clsBtn.btnLayerSet.bounds[1];
		var x2 = clsBtn.btnLayerSet.bounds[2];
		var y2 = clsBtn.btnLayerSet.bounds[3];

		var w = x2 - x1;
		var h = y2 - y1;

		var newDoc = app.documents.add(w * multiplyWidthBy,
										h * multiplyHeightBy,
										theDoc.resolution,
										clsBtn.btnLayerSet.name,
										NewDocumentMode.RGB,
										DocumentFill.TRANSPARENT,
										theDoc.pixelAspectRatio,
										theDoc.bitsPerChannel,
										theDoc.colorProfileName);

		newDoc.mode = theDoc.mode;

		app.activeDocument = theDoc;

		var newDocCurLayer = clsBtn.btnLayerSet.duplicate(newDoc);

		app.activeDocument = newDoc;

		newDocCurLayer.translate(-x1, -y1);

		// Remove nested buttons
		if (includeNestedButtons == true)
		{
			for (var nestedBtnIdx in clsBtn.arrNestedButtonsIdx)
			{
				var btnIdx = clsBtn.arrNestedButtonsIdx[nestedBtnIdx];

				newDocCurLayer.layers[btnIdx].remove();

				arrStateArrays = [clsBtn.arrNestedButtonsIdx, clsBtn.arrHitStateLayersIdx, clsBtn.arrUpStateLayersIdx, clsBtn.arrOverStateLayersIdx, clsBtn.arrDownStateLayersIdx];

				for (var arrStateIdx in arrStateArrays)
				{
					for (var arrBtnStateIdx in arrStateArrays[arrStateIdx])
					{
						if (arrStateArrays[arrStateIdx][arrBtnStateIdx] > btnIdx)
						{
							arrStateArrays[arrStateIdx][arrBtnStateIdx] -= 1;
						}
					}
				}
			}

			clsBtn.arrNestedButtonsIdx = [];

			// Recalculate button and canvas size.
			x1 = newDocCurLayer.bounds[0];
			y1 = newDocCurLayer.bounds[1];
			x2 = newDocCurLayer.bounds[2];
			y2 = newDocCurLayer.bounds[3];

			var oldW = w;
			var oldH = h;

			w = x2 - x1;
			h = y2 - y1;

			newDocCurLayer.translate(-x1, -y1);

			newDoc.resizeCanvas(w * multiplyWidthBy, h * multiplyHeightBy, AnchorPosition.MIDDLELEFT);
		}

		// Create state cells
		var iState = 0;

		if (insertHitRect == false)
		{
			iState = 1;
		}

		while (iState < 4)
		{
			newCellLayer = newDocCurLayer.duplicate(newDocCurLayer, ElementPlacement.PLACEBEFORE);
			renameDuplicatedLayers(newDocCurLayer, newCellLayer);

			var multiplyBy = iState;

			if (insertHitRect == false)
			{
				multiplyBy -= 1;
			}

			if (horizontalStrip == true)
			{
				newCellLayer.translate(w * multiplyBy, 0);
			}
			else
			{
				newCellLayer.translate(0, h * multiplyBy);
			}

			if (iState == 0)	// Hit
			{
				newCellLayer.name = "HIT";
				showHideLayers(newCellLayer, [clsBtn.arrNestedButtonsIdx, clsBtn.arrUpStateLayersIdx, clsBtn.arrOverStateLayersIdx, clsBtn.arrDownStateLayersIdx], false);

				if (clsBtn.arrHitStateLayersIdx.length == 0)
				{
					newCellLayer.visible = false;
				}
			}
			else if (iState == 1)	// Up
			{
				newCellLayer.name = "UP";
				showHideLayers(newCellLayer, [clsBtn.arrNestedButtonsIdx, clsBtn.arrHitStateLayersIdx, clsBtn.arrOverStateLayersIdx, clsBtn.arrDownStateLayersIdx], false);

				if (clsBtn.arrUpStateLayersIdx.length == 0)
				{
					newCellLayer.visible = false;
				}
			}
			else if (iState == 2)	// Over
			{
				newCellLayer.name = "OVER";
				showHideLayers(newCellLayer, [clsBtn.arrNestedButtonsIdx, clsBtn.arrHitStateLayersIdx, clsBtn.arrUpStateLayersIdx, clsBtn.arrDownStateLayersIdx], false);

				if (clsBtn.arrOverStateLayersIdx.length == 0)
				{
					newCellLayer.visible = false;
				}
			}
			else if (iState == 3)	// Down
			{
				newCellLayer.name = "DOWN";
				showHideLayers(newCellLayer, [clsBtn.arrNestedButtonsIdx, clsBtn.arrHitStateLayersIdx, clsBtn.arrUpStateLayersIdx, clsBtn.arrOverStateLayersIdx], false);

				if (clsBtn.arrDownStateLayersIdx.length == 0)
				{
					newCellLayer.visible = false;
				}
			}

			iState++;
		}

		newDocCurLayer.remove();
		newDoc.layers[newDoc.layers.length - 1].remove();

		newDoc.selection.deselect();
	}

	app.activeDocument = theDoc;

	//theDoc.selection.deselect();
}

/*****************************************************************************/

function renameDuplicatedLayers(srcLayerSet, trgLayerSet)
{
	for (var layerIdx = 0; layerIdx <= srcLayerSet.layers.length - 1; layerIdx++)
	{
		trgLayerSet.layers[layerIdx].name = srcLayerSet.layers[layerIdx].name;
	}
}

/*****************************************************************************/

function showHideLayers(curLayer, arrStateArrays, layerVisible)
{
	for (var arrStateIdx in arrStateArrays)
	{
		for (var arrBtnStateIdx in arrStateArrays[arrStateIdx])
		{
			curLayer.layers[arrStateArrays[arrStateIdx][arrBtnStateIdx]].visible = layerVisible;
		}
	}
}

/*****************************************************************************/

function main()
{
	var arrButtons = [];

	if (app.documents.length === 0)
	{
		alert("No open file.", "Error!!!", true);
		return false;
	}

	var doc = app.activeDocument;

	doc.selection.deselect();

	findButtonLayerSets(doc, arrButtons);

	createButtons(doc, arrButtons);

	doc.selection.deselect();

	alert("Done!!!");

	return true;
}
/*****************************************************************************/

main();
