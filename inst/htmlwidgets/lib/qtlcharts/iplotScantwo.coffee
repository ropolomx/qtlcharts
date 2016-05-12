# iplotScantwo: interactive plot of scantwo results (2-dim, 2-QTL genome scan)
# Karl W Broman

iplotScantwo = (widgetdiv, scantwo_data, pheno_and_geno, chartOpts) ->

    # chartOpts start
    height = chartOpts?.height ? 1200                  # total height of chart in pixels
    width = chartOpts?.width ? 1100                    # total width of chart in pixels
    chrGap = chartOpts?.chrGap ? 2                     # gaps between chr in heat map
    wright = chartOpts?.wright ? width/2               # width (in pixels) of right panels
    hbot = chartOpts?.hbot ? height/5                  # height (in pixels) of each of the lower panels
    margin = chartOpts?.margin ? {left:60, top:50, right:10, bottom: 40, inner: 5} # margins in each panel
    axispos = chartOpts?.axispos ? {xtitle:25, ytitle:30, xlabel:5, ylabel:5}      # axis positions in heatmap
    rectcolor = chartOpts?.rectcolor ? "#e6e6e6"       # color for background rectangle
    altrectcolor = chartOpts?.altrectcolor ? "#c8c8c8" # alternate rectangle in lower panels
    nullcolor = chartOpts?.nullcolor ? "#e6e6e6"       # color of null pixels in heat map
    boxcolor = chartOpts?.boxcolor ? "black"           # color of box around each panel
    boxwidth = chartOpts?.boxwidth ? 2                 # width of box around each panel
    linecolor = chartOpts?.linecolor ? "slateblue"     # line color in lower panels
    linewidth = chartOpts?.linewidth ? 2               # line width in lower panels
    pointsize = chartOpts?.pointsize ? 2               # point size in right panels
    pointstroke = chartOpts?.pointstroke ? "black"     # color of outer circle in right panels
    cicolors = chartOpts?.cicolors ? null              # colors for CIs in QTL effect plot; also used for points in phe x gen plot
    segwidth = chartOpts?.segwidth ? 0.4               # segment width in CI chart as proportion of distance between categories
    color = chartOpts?.color ? "slateblue"             # color for heat map
    oneAtTop = chartOpts?.oneAtTop ? false             # whether to put chr 1 at top of heatmap
    zthresh = chartOpts?.zthresh ? 0                   # LOD values below this threshold aren't shown (on LOD_full scale)
    # chartOpts end

    # htmlwidget div element containing the chart, and its ID
    div = d3.select(widgetdiv)
    widgetdivid = div.attr("id")
    svg = div.select("svg")

    # force chrnames to be a list
    scantwo_data.chrnames = d3panels.forceAsArray(scantwo_data.chrnames)
    scantwo_data.nmar = d3panels.forceAsArray(scantwo_data.nmar)

    # size of heatmap region
    w = d3.min([height-hbot*2, width-wright])
    heatmap_width =  w
    heatmap_height = w

    hright = heatmap_height/2
    width = heatmap_width + wright
    height = heatmap_height + hbot*2
    wbot = width/2

    # selected LODs on left and right
    leftvalue = "int"
    rightvalue = "fv1"

    # cicolors: check they're the right length or construct them
    if pheno_and_geno?
        gn = pheno_and_geno.genonames
        ncat = d3.max(gn[x].length for x of gn)
        if cicolors? # cicolors provided; expand to ncat
            cicolors = d3panels.expand2vector(cicolors, ncat)
            n = cicolors.length
            if n < ncat # not enough, display error
                d3panels.displayError("length(cicolors) (#{n}) < maximum no. genotypes (#{ncat})")
                cicolors = (cicolors[i % n] for i in [0...ncat])
        else # not provided; select them
            cicolors = d3panels.selectGroupColors(ncat, "dark")

    # drop-down menus
    options = ["full", "fv1", "int", "add", "av1"]
    form = div.insert("div", ":first-child")
              .attr("id", "form")
              .attr("class", "qtlcharts")
              .attr("height", "24px")
    left = form.append("div")
              .text(if oneAtTop then "bottom-left: " else "top-left: ")
              .style("float", "left")
              .style("margin-left", "50px")
    leftsel = left.append("select")
                  .attr("id", "leftselect_#{widgetdivid}")
                  .attr("name", "left")
    leftsel.selectAll("empty")
           .data(options)
           .enter()
           .append("option")
           .attr("value", (d) -> d)
           .text((d) -> d)
           .attr("selected", (d) ->
               return "selected" if d==leftvalue
               null)
    right = form.append("div")
                .text(if oneAtTop then "top-right: " else "bottom-right: ")
                .style("float", "left")
                .style("margin-left", "50px")
    rightsel = right.append("select")
                    .attr("id", "rightselect_#{widgetdivid}")
                    .attr("name", "right")
    rightsel.selectAll("empty")
            .data(options)
            .enter()
            .append("option")
            .attr("value", (d) -> d)
            .text((d) -> d)
            .attr("selected", (d) ->
                return "selected" if d==rightvalue
                null)
    submit = form.append("div")
                 .style("float", "left")
                 .style("margin-left", "50px")
                 .append("button")
                 .attr("name", "refresh")
                 .text("Refresh")
                 .on "click", () ->
                     leftsel = document.getElementById("leftselect_#{widgetdivid}")
                     leftvalue = leftsel.options[leftsel.selectedIndex].value
                     rightsel = document.getElementById("rightselect_#{widgetdivid}")
                     rightvalue = rightsel.options[rightsel.selectedIndex].value

                     scantwo_data.lod = lod_for_heatmap(scantwo_data, leftvalue, rightvalue)
                     div.select("g#chrheatmap svg").remove()
                     mylod2dheatmap(div.select("g#chrheatmap"), scantwo_data)
                     add_cell_tooltips()

    # add the full,add,int,fv1,av1 lod matrices to scantwo_data
    # (and remove the non-symmetric ones)
    scantwo_data = add_symmetric_lod(scantwo_data)

    scantwo_data.lod = lod_for_heatmap(scantwo_data, leftvalue, rightvalue)

    mylod2dheatmap = d3panels.lod2dheatmap({
        height:heatmap_height
        width:heatmap_width
        chrGap:chrGap
        axispos:axispos
        rectcolor:"white"
        nullcolor:nullcolor
        boxcolor:boxcolor
        colors:["white",color]
        zlim:[0, scantwo_data.max.full]
        zthresh:zthresh
        oneAtTop:oneAtTop
        tipclass:widgetdivid})

    g_heatmap = svg.append("g")
                   .attr("id", "chrheatmap")
    mylod2dheatmap(g_heatmap, scantwo_data)

    # function to add tool tips and handle clicking
    add_cell_tooltips = () ->
        mylod2dheatmap.celltip()
                      .html((d) ->
                            mari = scantwo_data.marker[d.xindex]
                            marj = scantwo_data.marker[d.yindex]
                            if +d.xindex > +d.yindex                # +'s ensure number not string
                                leftlod = d3.format(".1f")(scantwo_data[leftvalue][d.xindex][d.yindex])
                                rightlod = d3.format(".1f")(scantwo_data[rightvalue][d.yindex][d.xindex])
                                return "(#{marj} #{mari}) #{rightvalue} = #{rightlod}, #{leftvalue} = #{leftlod}"
                            else if +d.yindex > +d.xindex
                                leftlod = d3.format(".1f")(scantwo_data[leftvalue][d.yindex][d.xindex])
                                rightlod = d3.format(".1f")(scantwo_data[rightvalue][d.xindex][d.yindex])
                                return "(#{marj} #{mari}) #{leftvalue} = #{leftlod}, #{rightvalue} = #{rightlod}"
                            else
                                return mari
                            )

        mylod2dheatmap.cells()
                      .on "click", (d) ->
                                 mari = scantwo_data.marker[d.xindex]
                                 marj = scantwo_data.marker[d.yindex]
                                 return null if d.xindex == d.yindex # skip the diagonal case
                                 # plot the cross-sections as genome scans, below
                                 plot_scan(d.xindex, 0, 0, leftvalue)
                                 plot_scan(d.xindex, 1, 0, rightvalue)
                                 plot_scan(d.yindex, 0, 1, leftvalue)
                                 plot_scan(d.yindex, 1, 1, rightvalue)
                                 # plot the effect plot and phe x gen plot to right
                                 if pheno_and_geno?
                                     plot_effects(d.xindex, d.yindex)

    add_cell_tooltips()

    # to hold groups and positions of scan and effect plots
    mylodchart = [[null,null], [null,null]]
    scans_hpos = [0, wbot]
    scans_vpos = [heatmap_height, heatmap_height+hbot]

    mydotchart = null
    mycichart = null
    eff_hpos = [heatmap_width, heatmap_width]
    eff_vpos = [0, heatmap_height/2]

    g_scans = [[null,null],[null,null]]
    plot_scan = (markerindex, panelrow, panelcol, lod) ->
        data =
            chrname: scantwo_data.chrnames
            chr: scantwo_data.chr
            pos: scantwo_data.pos
            lod: (x for x in scantwo_data[lod][markerindex])
            marker: scantwo_data.marker

        mylodchart[panelrow][panelcol].remove() if mylodchart[panelrow][panelcol]?

        mylodchart[panelrow][panelcol] = d3panels.lodchart({
            height:hbot
            width:wbot
            margin:margin
            axispos:axispos
            ylim:[0.0, scantwo_data.max[lod]*1.05]
            rectcolor:rectcolor
            altrectcolor:altrectcolor
            linewidth:linewidth
            linecolor:linecolor
            pointsize:0
            pointcolor:""
            pointstroke:""
            lodvarname:"lod"
            xlab:""
            title:"#{data.marker[markerindex]} : #{lod}"
            tipclass:widgetdivid})

        unless g_scans[panelrow][panelcol]? # only create it once
            g_scans[panelrow][panelcol] = svg.append("g")
                         .attr("id", "scan_#{panelrow+1}_#{panelcol+1}")
                         .attr("transform", "translate(#{scans_hpos[panelcol]}, #{scans_vpos[panelrow]})")
        mylodchart[panelrow][panelcol](g_scans[panelrow][panelcol], data)

    g_eff = [null, null]
    plot_effects = (markerindex1, markerindex2) ->
        mar1 = scantwo_data.marker[markerindex1]
        mar2 = scantwo_data.marker[markerindex2]
        g1 = pheno_and_geno.geno[mar1]
        g2 = pheno_and_geno.geno[mar2]
        chr1 = pheno_and_geno.chr[mar1]
        chr2 = pheno_and_geno.chr[mar2]
        gnames1 = pheno_and_geno.genonames[chr1]
        gnames2 = pheno_and_geno.genonames[chr2]
        ng1 = gnames1.length
        ng2 = gnames2.length

        g = (g1[i] + (g2[i]-1)*ng1 for i of g1)
        gn1 = []
        gn2 = []
        cicolors_expanded = []
        for i in [0...ng2]
            for j in [0...ng1]
                gn1.push(gnames1[j])
                gn2.push(gnames2[i])
                cicolors_expanded.push(cicolors[i])

        mydotchart.remove() if mydotchart?
        mycichart.remove() if mycichart?

        pxg_data =
            x:g
            y:pheno_and_geno.pheno
            indID:pheno_and_geno.indID

        mydotchart = d3panels.dotchart({
            height:hright
            width:wright
            margin:margin
            axispos:axispos
            rectcolor:rectcolor
            pointsize:pointsize
            pointstroke:pointstroke
            xcategories:[1..gn1.length]
            xcatlabels:gn1
            xlab:""
            ylab:"Phenotype"
            yvar:"y"
            dataByInd:false
            title:"#{mar1} : #{mar2}"
            tipclass:widgetdivid})

        unless g_eff[1]? # only create it once
            g_eff[1] = svg.append("g")
                          .attr("id", "eff_1")
                          .attr("transform", "translate(#{eff_hpos[1]}, #{eff_vpos[1]})")
        mydotchart(g_eff[1], pxg_data)

        # revise point colors
        mydotchart.points()
                  .attr("fill", (d,i) ->
                          cicolors_expanded[g[i]-1])

        cis = d3panels.ci_by_group(g, pheno_and_geno.pheno, 2)
        ci_data =
            mean: (cis[x]?.mean ? null for x in [1..gn1.length])
            low:  (cis[x]?.low ? null for x in [1..gn1.length])
            high: (cis[x]?.high ? null for x in [1..gn1.length])
            categories: [1..gn1.length]

        mycichart = d3panels.cichart({
            height:hright
            width:wright
            margin:margin
            axispos:axispos
            rectcolor:rectcolor
            segcolor:cicolors_expanded
            segwidth:segwidth
            vertsegcolor:cicolors_expanded
            segstrokewidth:linewidth
            xlab:""
            ylab:"Phenotype"
            xcatlabels:gn1
            title:"#{mar1} : #{mar2}"
            tipclass:widgetdivid})

        unless g_eff[0]? # only create it once
            g_eff[0] = svg.append("g")
                          .attr("id", "eff_0")
                          .attr("transform", "translate(#{eff_hpos[0]}, #{eff_vpos[0]})")
        mycichart(g_eff[0], ci_data)
        effcharts = [mydotchart, mycichart]

        # add second row of labels
        for p in [0..1]
            effcharts[p].svg() # second row of genotypes
                    .append("g").attr("class", "x axis")
                    .selectAll("empty")
                    .data(gn2)
                    .enter()
                    .append("text")
                    .attr("x", (d,i) -> mydotchart.xscale()(i+1))
                    .attr("y", hright-margin.bottom/2+axispos.xlabel)
                    .text((d) -> d)
            effcharts[p].svg() # marker name labels
                    .append("g").attr("class", "x axis")
                    .selectAll("empty")
                    .data([mar1, mar2])
                    .enter()
                    .append("text")
                    .attr("x", (margin.left + mydotchart.xscale()(1))/2.0)
                    .attr("y", (d,i) ->
                        hright - margin.bottom/(i+1) + axispos.xlabel)
                    .style("text-anchor", "end")
                    .text((d) -> d + ":")

# add full,add,int,av1,fv1 lod scores to scantwo_data
add_symmetric_lod = (scantwo_data) ->
    scantwo_data.full = scantwo_data.lod.map (d) -> d.map (dd) -> dd
    scantwo_data.add  = scantwo_data.lod.map (d) -> d.map (dd) -> dd
    scantwo_data.fv1  = scantwo_data.lodv1.map (d) -> d.map (dd) -> dd
    scantwo_data.av1  = scantwo_data.lodv1.map (d) -> d.map (dd) -> dd
    scantwo_data.int  = scantwo_data.lod.map (d) -> d.map (dd) -> dd

    for i in [0...(scantwo_data.lod.length-1)]
        for j in [i...scantwo_data.lod[i].length]
            scantwo_data.full[i][j] = scantwo_data.lod[j][i]
            scantwo_data.add[j][i]  = scantwo_data.lod[i][j]
            scantwo_data.fv1[i][j]  = scantwo_data.lodv1[j][i]
            scantwo_data.av1[j][i]  = scantwo_data.lodv1[i][j]

    scantwo_data.one = []
    for i in [0...scantwo_data.lod.length]
        scantwo_data.one.push(scantwo_data.lod[i])
        for j in [0...scantwo_data.lod.length]
            scantwo_data.int[i][j] = scantwo_data.full[i][j] - scantwo_data.add[i][j]

    # delete the non-symmetric versions
    scantwo_data.lod = null
    scantwo_data.lodv1 = null

    scantwo_data.max = {}
    for i in ["full", "add", "fv1", "av1", "int"]
        scantwo_data.max[i] = d3panels.matrixMax(scantwo_data[i])

    scantwo_data

lod_for_heatmap = (scantwo_data, left, right) ->
    # make copy of lod
    z = scantwo_data.full.map (d) -> d.map (dd) -> dd

    for i in [0...z.length]
        for j in [0...z.length]
            thelod = if j < i then right else left
            z[i][j] = scantwo_data[thelod][i][j]/scantwo_data.max[thelod]*scantwo_data.max["full"]

    z # return the matrix we created
