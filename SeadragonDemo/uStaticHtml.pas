unit uStaticHtml;

interface

const
   MAIN_PAGE =
      '<!DOCTYPE html>                                                                                            '#10 +
      '<html>                                                                                                     '#10 +
      '    <head>                                                                                                 '#10 +
      '        <script type="text/javascript" src="seadragon-min.js">                                             '#10 +
      '        </script>                                                                                          '#10 +
      '        <script type="text/javascript">                                                                    '#10 +
      '            var viewer = null;                                                                             '#10 +
      '                                                                                                           '#10 +
      '            function DummyTileSource(width, height) {                                                      '#10 +
      '                Seadragon.TileSource.apply(this, [width, height, Math.max(width, height)]);                '#10 +
      '                                                                                                           '#10 +
      '                this.tileSize = 100;                                                                       '#10 +
      '                                                                                                           '#10 +
      '                this.getTileUrl = function(level, x, y) {                                                  '#10 +
      '                                      return "getTile/" + level + "/" + x + "/" + y;                       '#10 +
      '                                  };                                                                       '#10 +
      '            }                                                                                              '#10 +
      '                                                                                                           '#10 +
      '            function init() {                                                                              '#10 +
      '                Seadragon.Config.imagePath="/imgs/";                                                       '#10 +
      '                viewer = new Seadragon.Viewer("container");                                                '#10 +
      '                viewer.openTileSource(                                                                     '#10 +
      '                    new DummyTileSource(%W_H%));                                                           '#10 +
      '            }                                                                                              '#10 +
      '                                                                                                           '#10 +
      '            Seadragon.Utils.addEvent(window, "load", init);                                                '#10 +
      '        </script>                                                                                          '#10 +
      '                                                                                                           '#10 +
      '        <style type="text/css">                                                                            '#10 +
      '            body                                                                                           '#10 +
      '            {                                                                                              '#10 +
      '                background-color: gray;                                                                    '#10 +
      '            }                                                                                              '#10 +
      '            #container                                                                                     '#10 +
      '            {                                                                                              '#10 +
      '                width: 500px;                                                                              '#10 +
      '                height: 400px;                                                                             '#10 +
      '                background-color: black;                                                                   '#10 +
      '                border: 1px solid black;                                                                   '#10 +
      '                color: white;   /* for error messages, etc. */                                             '#10 +
      '            }                                                                                              '#10 +
      '        </style>                                                                                           '#10 +
      '                                                                                                           '#10 +
      '    </head>                                                                                                '#10 +
      '    <body>                                                                                                 '#10 +
      '        <div id="container"></div>                                                                         '#10 +
      '    </body>                                                                                                '#10 +
      '</html>                                                                                                    '#10;

implementation

end.
