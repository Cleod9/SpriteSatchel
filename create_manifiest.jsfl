var lib = fl.getDocumentDOM().library;
var manifest = "var manifest:Array = [\n";
for (var i = 0; i < lib.items.length; i++)
{
    var item = lib.items[i];
	if(item.itemType == "movie clip" && item.linkageExportForAS)
		manifest += "\t{ linkage: \"" + (item.linkageClassName) + "\" },\n";
}
var comma = manifest.lastIndexOf(",");
manifest = (comma > 0) ? manifest.substr(0, comma) + '\n' : manifest;
manifest += '];';
fl.getDocumentDOM().getTimeline().layers[0].frames[0].actionScript += "\n" + manifest;