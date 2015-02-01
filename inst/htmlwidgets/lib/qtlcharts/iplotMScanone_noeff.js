// Generated by CoffeeScript 1.8.0
var iplotMScanone_noeff;

iplotMScanone_noeff = function(lod_data, times, chartOpts) {
  var axispos, chartdivid, chr, chrGap, colors, curindex, curvechart_xaxis, darkrect, extra_digits, g_curvechart, g_heatmap, g_lodchart, hbot, htop, i, lightrect, linecolor, linewidth, lod4curves, lod_labels, lod_ylab, lodchart_curves, lodcolumn, lodcurve, margin, mycurvechart, mylodchart, mylodheatmap, nullcolor, nxticks, plotLodCurve, pos, posindex, svg, titlepos, totalh, totalw, wleft, wright, x, xscale, xticks, y, zlim, zthresh, _i, _j, _len, _len1, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref19, _ref2, _ref20, _ref21, _ref22, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  wleft = (_ref = chartOpts != null ? chartOpts.wleft : void 0) != null ? _ref : 650;
  wright = (_ref1 = chartOpts != null ? chartOpts.wright : void 0) != null ? _ref1 : 350;
  htop = (_ref2 = chartOpts != null ? chartOpts.htop : void 0) != null ? _ref2 : 350;
  hbot = (_ref3 = chartOpts != null ? chartOpts.hbot : void 0) != null ? _ref3 : 350;
  margin = (_ref4 = chartOpts != null ? chartOpts.margin : void 0) != null ? _ref4 : {
    left: 60,
    top: 40,
    right: 40,
    bottom: 40,
    inner: 5
  };
  axispos = (_ref5 = chartOpts != null ? chartOpts.axispos : void 0) != null ? _ref5 : {
    xtitle: 25,
    ytitle: 30,
    xlabel: 5,
    ylabel: 5
  };
  titlepos = (_ref6 = chartOpts != null ? chartOpts.titlepos : void 0) != null ? _ref6 : 20;
  chrGap = (_ref7 = chartOpts != null ? chartOpts.chrGap : void 0) != null ? _ref7 : 8;
  darkrect = (_ref8 = chartOpts != null ? chartOpts.darkrect : void 0) != null ? _ref8 : "#C8C8C8";
  lightrect = (_ref9 = chartOpts != null ? chartOpts.lightrect : void 0) != null ? _ref9 : "#E6E6E6";
  nullcolor = (_ref10 = chartOpts != null ? chartOpts.nullcolor : void 0) != null ? _ref10 : "#E6E6E6";
  colors = (_ref11 = chartOpts != null ? chartOpts.colors : void 0) != null ? _ref11 : ["slateblue", "white", "crimson"];
  zlim = (_ref12 = chartOpts != null ? chartOpts.zlim : void 0) != null ? _ref12 : null;
  zthresh = (_ref13 = chartOpts != null ? chartOpts.zthresh : void 0) != null ? _ref13 : null;
  lod_ylab = (_ref14 = chartOpts != null ? chartOpts.lod_ylab : void 0) != null ? _ref14 : "";
  linecolor = (_ref15 = chartOpts != null ? chartOpts.linecolor : void 0) != null ? _ref15 : "darkslateblue";
  linewidth = (_ref16 = chartOpts != null ? chartOpts.linewidth : void 0) != null ? _ref16 : 2;
  nxticks = (_ref17 = chartOpts != null ? chartOpts.nxticks : void 0) != null ? _ref17 : 5;
  xticks = (_ref18 = chartOpts != null ? chartOpts.xticks : void 0) != null ? _ref18 : null;
  lod_labels = (_ref19 = chartOpts != null ? chartOpts.lod_labels : void 0) != null ? _ref19 : null;
  chartdivid = (_ref20 = chartOpts != null ? chartOpts.chartdivid : void 0) != null ? _ref20 : 'chart';
  totalh = htop + hbot + 2 * (margin.top + margin.bottom);
  totalw = wleft + wright + 2 * (margin.left + margin.right);
  if (lod_labels == null) {
    lod_labels = times != null ? (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = times.length; _i < _len; _i++) {
        x = times[_i];
        _results.push(formatAxis(times, extra_digits = 1)(x));
      }
      return _results;
    })() : lod_data.lodnames;
  }
  mylodheatmap = lodheatmap().height(htop).width(wleft).margin(margin).axispos(axispos).titlepos(titlepos).chrGap(chrGap).rectcolor(lightrect).colors(colors).zlim(zlim).zthresh(zthresh).quantScale(times).lod_labels(lod_labels).ylab(lod_ylab).nullcolor(nullcolor);
  svg = d3.select("div#" + chartdivid).append("svg").attr("height", totalh).attr("width", totalw);
  g_heatmap = svg.append("g").attr("id", "heatmap").datum(lod_data).call(mylodheatmap);
  mylodchart = lodchart().height(hbot).width(wleft).margin(margin).axispos(axispos).titlepos(titlepos).chrGap(chrGap).linecolor("none").pad4heatmap(true).darkrect(darkrect).lightrect(lightrect).ylim([0, d3.max(mylodheatmap.zlim())]).pointsAtMarkers(false);
  g_lodchart = svg.append("g").attr("transform", "translate(0," + (htop + margin.top + margin.bottom) + ")").attr("id", "lodchart").datum(lod_data).call(mylodchart);
  lodcurve = function(chr, lodcolumn) {
    return d3.svg.line().x(function(d) {
      return mylodchart.xscale()[chr](d);
    }).y(function(d, i) {
      return mylodchart.yscale()(Math.abs(lod_data.lodByChr[chr][i][lodcolumn]));
    });
  };
  lodchart_curves = null;
  plotLodCurve = function(lodcolumn) {
    var chr, _i, _len, _ref21, _results;
    lodchart_curves = g_lodchart.append("g").attr("id", "lodcurves");
    _ref21 = lod_data.chrnames;
    _results = [];
    for (_i = 0, _len = _ref21.length; _i < _len; _i++) {
      chr = _ref21[_i];
      _results.push(lodchart_curves.append("path").datum(lod_data.posByChr[chr]).attr("d", lodcurve(chr, lodcolumn)).attr("stroke", linecolor).attr("fill", "none").attr("stroke-width", linewidth).style("pointer-events", "none"));
    }
    return _results;
  };
  lod4curves = {
    data: []
  };
  for (pos in lod_data.pos) {
    y = (function() {
      var _i, _len, _ref21, _results;
      _ref21 = lod_data.lodnames;
      _results = [];
      for (_i = 0, _len = _ref21.length; _i < _len; _i++) {
        lodcolumn = _ref21[_i];
        _results.push(Math.abs(lod_data[lodcolumn][pos]));
      }
      return _results;
    })();
    x = (function() {
      var _results;
      _results = [];
      for (i in lod_data.lodnames) {
        _results.push(+i);
      }
      return _results;
    })();
    lod4curves.data.push({
      x: x,
      y: y
    });
  }
  mycurvechart = curvechart().height(htop).width(wright).margin(margin).axispos(axispos).titlepos(titlepos).xlab(lod_ylab).ylab("LOD score").strokecolor("none").rectcolor(lightrect).xlim([-0.5, lod_data.lodnames.length - 0.5]).ylim([0, d3.max(mylodheatmap.zlim())]).nxticks(0).commonX(false);
  g_curvechart = svg.append("g").attr("transform", "translate(" + (wleft + margin.top + margin.bottom) + ",0)").attr("id", "curvechart").datum(lod4curves).call(mycurvechart);
  if (times != null) {
    xscale = d3.scale.linear().range(mycurvechart.xscale().range());
    xscale.domain([times[0], times[times.length - 1]]);
    xticks = xticks != null ? xticks : xscale.ticks(nxticks);
    curvechart_xaxis = g_curvechart.select("g.x.axis");
    curvechart_xaxis.selectAll("empty").data(xticks).enter().append("line").attr("x1", function(d) {
      return xscale(d);
    }).attr("x2", function(d) {
      return xscale(d);
    }).attr("y1", margin.top).attr("y2", margin.top + htop).attr("fill", "none").attr("stroke", "white").attr("stroke-width", 1).style("pointer-events", "none");
    curvechart_xaxis.selectAll("empty").data(xticks).enter().append("text").attr("x", function(d) {
      return xscale(d);
    }).attr("y", margin.top + htop + axispos.xlabel).text(function(d) {
      return formatAxis(xticks)(d);
    });
  } else {
    curvechart_xaxis = g_curvechart.select("g.x.axis").selectAll("empty").data(lod_labels).enter().append("text").attr("id", function(d, i) {
      return "xaxis" + i;
    }).attr("x", function(d, i) {
      return mycurvechart.xscale()(i);
    }).attr("y", margin.top + htop + axispos.xlabel).text(function(d) {
      return d;
    }).attr("opacity", 0);
  }
  posindex = {};
  curindex = 0;
  _ref21 = lod_data.chrnames;
  for (_i = 0, _len = _ref21.length; _i < _len; _i++) {
    chr = _ref21[_i];
    posindex[chr] = {};
    _ref22 = lod_data.posByChr[chr];
    for (_j = 0, _len1 = _ref22.length; _j < _len1; _j++) {
      pos = _ref22[_j];
      posindex[chr][pos] = curindex;
      curindex += 1;
    }
  }
  mycurvechart.curvesSelect().on("mouseover.panel", null).on("mouseout.panel", null);
  return mylodheatmap.cellSelect().on("mouseover", function(d) {
    var p;
    plotLodCurve(d.lodindex);
    g_lodchart.select("g.title text").text("" + lod_labels[d.lodindex]);
    g_curvechart.selectAll("path.path" + posindex[d.chr][d.pos]).attr("stroke", linecolor);
    p = d3.format(".1f")(d.pos);
    g_curvechart.select("g.title text").text("" + d.chr + "@" + p);
    if (times == null) {
      return g_curvechart.select("text#xaxis" + d.lodindex).attr("opacity", 1);
    }
  }).on("mouseout", function(d) {
    lodchart_curves.remove();
    g_lodchart.select("g.title text").text("");
    g_curvechart.selectAll("path.path" + posindex[d.chr][d.pos]).attr("stroke", null);
    g_curvechart.select("g.title text").text("");
    if (times == null) {
      return g_curvechart.select("text#xaxis" + d.lodindex).attr("opacity", 0);
    }
  });
};