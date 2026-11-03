import AppKit
let dir = URL(fileURLWithPath:CommandLine.arguments[1])
try FileManager.default.createDirectory(at:dir,withIntermediateDirectories:true)
for n in [16,32,128,256,512] {
 for scale in [1,2] {
  let px=n*scale
  let image=NSImage(size:NSSize(width:px,height:px))
  image.lockFocus()
  NSColor(calibratedRed:0.10,green:0.38,blue:0.32,alpha:1).setFill()
  NSBezierPath(roundedRect:NSRect(x:0,y:0,width:px,height:px),xRadius:CGFloat(px)*0.2,yRadius:CGFloat(px)*0.2).fill()
  if let symbol=NSImage(systemSymbolName:"cube",accessibilityDescription:nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize:CGFloat(px)*0.6,weight:.medium)) {
   let bounds=NSRect(x:CGFloat(px)*0.19,y:CGFloat(px)*0.18,width:CGFloat(px)*0.62,height:CGFloat(px)*0.64)
   symbol.withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors:[.white]))?.draw(in:bounds)
  }
  image.unlockFocus()
  let bitmap=NSBitmapImageRep(data:image.tiffRepresentation!)!
  let data=bitmap.representation(using:.png,properties:[:])!
  let name="icon_\(n)x\(n)"+(scale==2 ? "@2x" : "")+".png"
  try data.write(to:dir.appendingPathComponent(name))
 }
}
