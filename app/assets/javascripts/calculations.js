function calculations_create() {
    var set_id = $('#charts').attr('data-set-id');
    
    var chart = new Highcharts.Chart({
	    chart: {
		renderTo: 'january-chart',
		type: 'areaspline'
	    },

	    title: {
		text: 'Test Chart'
	    },

	    xAxis: {
		categories: [ 'Apples', 'Bannanas', 'Oranges' ]
	    },

	    yAxis: { 
		title: {
		    text: 'Fruit Eaten'
		}
	    },
	    series: [ {
		    name: 'Jane',
		    data: [1,0,4]
		},    {
		    name: 'John',
		    data: [5,7,3]
		}
		]
	});

}