run("Close All");
dir = getDirectory("Choose Source Directory ");
list = getFileList(dir);

ResultsTotal = newArray(2);
ResultsTotal[0]="sep=;";				
ResultsTotal[1]="Average Branch Distance;# of branches;# of sections;Average branch length;Main branch length;longest section"; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BranchTotal = newArray(2);
BranchTotal[0]="sep=;";				
BranchTotal[1]="Section length;Euclidean Dist length;Tortuosity"; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
for (q=0; q<list.length; q++) {
		
	if (endsWith(list[q], ".tif")){
		run("Close All");
		open(dir+"\\"+list[q]);
		setTool("polygon");
		run("Options...", "iterations=1 count=1");
		i=0;
		j=1;
		k=1;
		run("Set Scale...", "distance=1 known=0.17 pixel=1 unit=micron");
		tit=getTitle();
		while (j==1){
			if (selectionType==-1){
				waitForUser("Select the region you want to analyze, \n \n Select only one main branch! \n \n Select no overlapping hyphae \n this will hamper the measurements. \n \n Click OK without selection to skip the image");
			}
			if (selectionType!=-1){
				setBatchMode(true);
				run("Duplicate...", "title="+i);
				run("Select None");
				run("8-bit");
				run("Subtract Background...", "rolling=50 light");
				run("Gaussian Blur...", "sigma=2");
				run("Enhance Contrast", "saturated=0.05");

				setAutoThreshold("Default");
				run("Convert to Mask");
				run("Restore Selection");
				run("Clear Outside");
				run("Analyze Particles...", "  circularity=0.00-0.20 show=Masks clear");
				selectWindow("Mask of "+i);
				run("Skeletonize");
				run("Analyze Skeleton (2D/3D)", "prune=none calculate show");
				setBatchMode(false);
				if (nResults>0){
					J=getResult("# Junctions");
					S=getResult("# Branches");
					Av=getResult("Average Branch Length");
					Main=getResult("Longest Shortest Path");
					Long=getResult("Maximum Branch Length");
					AvBd=Main/J;
					if (i==0){
						ResultsTotal = Array.concat(ResultsTotal,""+tit);
					}
					ResultsTotal = Array.concat(ResultsTotal,""+AvBd+";"+J+";"+S+";"+Av+";"+Main+";"+Long);

					if(isOpen("Results")){
						selectWindow("Results");						//Results window is selected and...
						run("Close");									//...closed  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					}	

					selectWindow("Branch information");
					IJ.renameResults("Results");

					
					for (a=0;a<nResults;a++){
						SL=getResult("Branch length",a);
						EUD=getResult("Euclidean distance",a);
						Tor=SL/EUD;
						BranchTotal = Array.concat(BranchTotal,""+SL+";"+EUD+";"+Tor);
					}
				}
				
				if(isOpen("Results")){
					selectWindow("Results");						//Results window is selected and...
					run("Close");									//...closed  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				}
				selectWindow(tit);
				run("Restore Selection");
				run("Clear");
				run("Select None");
			} else {
				j=0;
			}
			i=i+1;
		}
	}
	if (q%5==0 &&q!=0){
		Array.show("Results",ResultsTotal);
		saveAs("Results", dir+"\\TempResults.csv");
		Array.show("Results",BranchTotal);
		saveAs("Results", dir+"\\TempBranch.csv");
	}
}
Array.show("Results",ResultsTotal);
saveAs("Results", dir+"\\Results.csv");
Array.show("Results",BranchTotal);
saveAs("Results", dir+"\\Branch.csv");

