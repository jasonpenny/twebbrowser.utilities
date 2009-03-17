unit uWBGoogleMaps;

interface

uses
   SysUtils, Forms, Graphics, Windows, Classes, ShDocVw,
   uWebBrowser;

type
  TWBGoogleMaps = class(TWBWrapper)
  private
    fLoadedGoogleMaps: Boolean;
  public
    constructor Create(const HostedBrowser: TWebBrowser);

    procedure LoadDefaultGoogleMapsDocument;

    property LoadedGoogleMaps: Boolean read fLoadedGoogleMaps;
  published
    property OnGetExternal;
  end;

implementation

constructor TWBGoogleMaps.Create(const HostedBrowser: TWebBrowser);
begin
   inherited;

   // my preferred defaults: no border, no scroll bars
   Show3DBorder := False;
   ShowScrollBars := False;
end;

procedure TWBGoogleMaps.LoadDefaultGoogleMapsDocument;
   const
      rootDoc: String =
         '<html>'#13#10 +
         '  <head>'#13#10 +
         '    <meta http-equiv="content-type" content="text/html"/>'#13#10 +
         '    <title>Google Maps JavaScript API Example</title>'#13#10 +
         '    <script src="http://maps.google.com/maps?file=api&amp;v=2" type="text/javascript"></script>'#13#10 +
         '    <script type="text/javascript">'#13#10 +
         ''#13#10 +
         '      var map;'#13#10 +
         '    //<![CDATA['#13#10 +
         ''#13#10 +
         '    function load() {'#13#10 +
         '      if (GBrowserIsCompatible()) {'#13#10 +
         '        map = new GMap2(document.getElementById("map"));'#13#10 +
         '        map.addControl(new GLargeMapControl());'#13#10 +
         '        map.addControl(new GMapTypeControl());'#13#10 +
         '        map.addControl(new GScaleControl());'#13#10 +
         '        map.enableScrollWheelZoom();'#13#10 +
         '        map.setCenter(new GLatLng(37.05173494, -122.03160858), 13);'#13#10 +
         '      }'#13#10 +
         '    }'#13#10 +
         ''#13#10 +
         '    //]]>'#13#10 +
         '    </script>'#13#10 +
         '  </head>'#13#10 +
         ''#13#10 +
         '  <body onload="load()" onunload="GUnload()" style="margin:0">'#13#10 +
         '    <div id="map" style="width: 100%; height: 300px"></div>'#13#10 +
         '  </body>'#13#10 +
         '</html>';
begin
   LoadHTML(rootDoc, true);
   fLoadedGoogleMaps := true;
end;

end.
