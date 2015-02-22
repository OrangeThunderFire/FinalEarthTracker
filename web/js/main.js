var element = document.getElementById("map");

var map = new Datamap({
    element: element,
    geographyConfig: {
        dataUrl: 'js/world.json'
    },
    fills: {
    },
    data: {},
    responsive: true
});
console.log(map);
window.addEventListener('resize', function() {
    map.resize();
});

function indexCountryCodes (by) {
    var cc = {};
    for (var i = 0; i < countryCodes.length; i++) {
        cc[countryCodes[i][by]] = countryCodes[i];
    }
    return cc;
}
function updateMap(data) {
    var cCode = indexCountryCodes("alpha2");
    var mapOutput = {};
    var countries = data.world.countries;
    for (var i = 0; i < countries.length; i++) {
        var country = countries[i];
        if (cCode.hasOwnProperty(country.countryCode)) {
            var alpha3 = cCode[country.countryCode].alpha3;
            if (alpha3 != null) {
                var attr = country.controllingTeam == "Axis" ? "url(#axis)" : country.controllingTeam == "Allies" ? "url(#allies)" : "url(#neutral)";
                console.log(attr);
                mapOutput[alpha3] = {
                    fillAttr: attr,
                    className: country.controllingTeam.toLowerCase()
                };
            }
        }
    }
    map.updateChoropleth(mapOutput);
}

(function () {
    window.requestAnimationFrame(reDraw);
    var removeFilter = false;
    var lastFilterTime = 0;
    var svg = null;
    function reDraw(num) {
        window.requestAnimationFrame(reDraw);
        if (svg == null) {
            svg = document.querySelectorAll("svg g.datamaps-subunits")[0];
        }
        else {
            var timeSinceFilter = Date.now() - lastFilterTime;
            if (!removeFilter) {
                if (timeSinceFilter >= 10000 && Math.random() < 0.004) {
                    d3.select(svg).attr("filter", "url(#glitch)");
                    lastFilterTime = Date.now();
                    removeFilter = true;
                }
            }
            else {
                if (timeSinceFilter > (Math.random() * 400)) {
                    d3.select(svg).attr("filter", "");
                    removeFilter = false;
                }
            }
        }
    }
})();