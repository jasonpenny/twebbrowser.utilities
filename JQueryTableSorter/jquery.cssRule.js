/* Copyright (c) 2008 Gilberto Saraiva (saraivagilberto@gmail.com || http://gsaraiva.projects.pro.br)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * Version: 2008.0.1.9 -
 * Under development and testing
 *
 * Requires: jQuery 1.2+
 *
 * Support/Site: http://gsaraiva.projects.pro.br/openprj/?page=jquerycssrule
 */

(function( $ ){
  $.cssRule = function (Selector, Property, Value) {

    // Selector == {}
    if(typeof Selector == "object"){
      $.each(Selector, function(NewSelector, NewProperty){
        $.cssRule(NewSelector, NewProperty);
      });
      return;
    }

    // Selector == "body:background:#F99"
    if((typeof Selector == "string") && (Selector.indexOf(":") > -1)
      && (Property == undefined) && (Value == undefined)){
      Data = Selector.split("{");
      Data[1] = Data[1].replace(/\}/, "");
      $.cssRule($.trim(Data[0]), $.trim(Data[1]));
      return;
    }

    // Check for multi-selector, [ IE don't accept multi-selector on this way, we need to split ]
    if((typeof Selector == "string") && (Selector.indexOf(",") > -1)){
      Multi = Selector.split(",");
      for(x = 0; x < Multi.length; x++){
        Multi[x] = $.trim(Multi[x]);
        if(Multi[x] != "")
          $.cssRule(Multi[x], Property, Value);
      }

      return;
    }

    // Porperty == {} or []
    if(typeof Property == "object"){

      // Is {}
      if(Property.length == undefined){

        // Selector, {}
        $.each(Property, function(NewProperty, NewValue){
          $.cssRule(Selector + " " + NewProperty, NewValue);
        });

      // Is [Prop, Value]
      }else if((Property.length == 2) && (typeof Property[0] == "string") &&
        (typeof Property[1] == "string")){
        $.cssRule(Selector, Property[0], Property[1]);

      // Is array of settings
      }else{
        for(x1 = 0; x1 < Property.length; x1++){
          $.cssRule(Selector, Property[x1], Value);
        }
      }

      return;
    }

    // Parse for property at CSS Style "{property:value}"
    if((typeof Property == "string") && (Property.indexOf("{") > -1)
       && (Property.indexOf("}") > -1)){
      Property = Property.replace(/\{/, "").replace(/\}/, "");
    }

    // Check for multiple properties
    if((typeof Property == "string") && (Property.indexOf(";") > -1)){
      Multi1 = Property.split(";");
      for(x2 = 0; x2 < Multi1.length; x2++){
        $.cssRule(Selector, Multi1[x2], undefined);
      }
      return;
    }

    // Check for property:value
    if((typeof Property == "string") && (Property.indexOf(":") > -1)){
      Multi3 = Property.split(":");
      $.cssRule(Selector, Multi3[0], Multi3[1]);
      return;
    }

    //********************************************
    // Logical CssRule additions
    // Check for multiple logical properties [ "padding,margin,border:0px" ]
    if((typeof Property == "string") && (Property.indexOf(",") > -1)){
      Multi2 = Property.split(",");
      for(x3 = 0; x3 < Multi2.length; x3++){
        $.cssRule(Selector, Multi2[x3], Value);
      }
      return;
    }

    //********************************************
    // Check for Most One Style Sheet
    // jQuery.CssRule need at last one Style Sheet enabled on the page.
    styleSheetsLength = document.styleSheets.length;
    if(styleSheetsLength <= 1){
      // Append for no IE browsers
      if(!document.createStyleSheet){
        var styleSheet = (typeof document.createElementNS != undefined) ?
          document.createElementNS("http://www.w3.org/1999/xhtml", "style") :
          document.createElement("style");
        styleSheet.setAttribute("type", "text/css");
        styleSheet.setAttribute("media", "screen");
        if(styleSheetsLength == 0){
          $($("html")[0]).prepend(styleSheet);
        }
      // Append for IE
      }else{
        BaseStyle = document.getElementsByTagName("style");
        if(BaseStyle.length > 0)
          document.getElementsByTagName("style")[0].disabled = false;
        var styleSheet = document.createElement("style");
        styleSheet.setAttribute("type", "text/css");
        styleSheet.setAttribute("media", "screen");
        styleSheet.disabled = false;
        $($("html")[0]).prepend(styleSheet);
      }
    }

    if((Property == undefined) || (Value == undefined))
      return;

    Selector = $.trim(Selector);
    Property = $.trim(Property);
    Value = $.trim(Value.replace('|', ':')); // allow url(res://...) by passing url(res|//...)

    if((Property == "") || (Value == ""))
      return;

    // adjusts on property 
    if($.browser.msie){
      // for IE (@.@)^^^
      switch(Property){
        case "float": Property = "style-float"; break;
      }
    }else{
      // CSS rights
      switch(Property){
        case "float": Property = "css-float"; break;
      }
    }

    CssProperty = (Property || "").replace(/\-(\w)/g, function(m, c){ return (c.toUpperCase()); });

    for(var i = 0; i < document.styleSheets.length; i++){
      CurrentStyleSheet = document.styleSheets[i];
      Rules = (CurrentStyleSheet.cssRules || CurrentStyleSheet.rules);
      LowerSelector = Selector.toLowerCase();

      for(var i2 = 0, len = Rules.length; i2 < len; i2++){
        if(Rules[i2].selectorText && (Rules[i2].selectorText.toLowerCase() == LowerSelector)){
          if(Value != null){
            Rules[i2].style[CssProperty] = Value;
            return;
          }else{
            if(CurrentStyleSheet.deleteRule){
              CurrentStyleSheet.deleteRule(i2);
            }else if(CurrentStyleSheet.removeRule){
              CurrentStyleSheet.removeRule(i2);
            }else{
              Rules[i2].style.cssText = "";
            }
          }
        }
      }
    }

    if(Property && Value){
      for(var i = 0; i < document.styleSheets.length; i++){
        WorkerStyleSheet = document.styleSheets[i];
        if(WorkerStyleSheet.insertRule){
          Rules = (WorkerStyleSheet.cssRules || WorkerStyleSheet.rules);
          WorkerStyleSheet.insertRule(Selector + "{ " + Property + ":" + Value + "; }", Rules.length);
        }else if(WorkerStyleSheet.addRule){
          WorkerStyleSheet.addRule(Selector, Property + ":" + Value + ";", 0);
        }else{
          throw new Error("Add/insert not enabled.");
        }
      }
    }
  };
  
  $.tocssRule = function(cssText){
    matchRes = cssText.match(/(.*?)\{(.*?)\}/);
    while(matchRes){
      cssText = cssText.replace(/(.*?)\{(.*?)\}/, "");
      $.cssRule(matchRes[1], matchRes[2]);
      matchRes = cssText.match(/(.*?)\{(.*?)\}/);
    }
  }
})( jQuery );