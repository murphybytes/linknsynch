function to_month_name( n ) {
    var result = 'ERR';
    switch( n ) {
    case '1':
	result = 'Jan';
	break;
    case '2':
	result = 'Feb';
	break;
    case '3':
	result = 'Mar';
	break;
    case '4':
	result = 'Apr';
	break;
    case '5':
	result = 'May';
	break;
    case '6' :
	result = 'Jun';
	break;
    case '7' :
	result = 'Jul';
	break;
    case '8' : 
	result = 'Aug';
	break;
    case '9' :
	result = 'Sep';
	break;
    case '10' :
	result = 'Oct';
	break ;
    case '11' :
	result = 'Nov';
	break;
    case '12' :
	result = 'Dec';
	break;

    }

    return result;    
}

function calculations_create() {
    var set_id = $('#charts').attr('data_set_id');
    var home_profile_ids = new Array();
    $('.home-profile-id').each(function() { 
	home_profile_ids.push( $(this).attr('value') );
    });

//    var home_profile_id = $('#charts').attr('home_profile_id');
    var thermal_storage_ids = new Array();
    $('.thermal-storage-id').each(function() { 
	thermal_storage_ids.push( $(this).attr('value') );
    });

    var months = new Array();
    $('.chart-month').each( function() {
	var month = $(this).attr('month');
	var year = $(this).attr('year');


	$.get(
	    'graphs/unservedsummary.json',
	    {
		month: month,
		year: year,
		set_id: set_id,
		'home_profile_ids[]': home_profile_ids,
		'thermal_storage_ids[]': thermal_storage_ids
	    },

	    function(data) {
		//console.info( data );
		var chart = new Highcharts.Chart({
		    chart: {
			renderTo: data.year + '.' + data.month + '.4',
			type: 'column'
		    },

		    title: {
			text: 'Load Unserved'
		    },
		    subtitle: {
			text: to_month_name( data.month ) + ' ' + data.year
		    },
		    legend: {
			enabled: false
		    },
		    xAxis: {
			categories: [ 'Unserved', 'Unserved LS' ]
		    },

		    yAxis: { 
			endOnTick: false,
			min: data.min_y,
			labels: {
			    enabled: true
			},
			title: {
			    text: 'kWh'
			}
		    },
		    series: [ {
			data: [data.load_unserved, data.load_unserved_ls ]


		    }
			    ]
		});
	    }
	);


	$.get(
	    'graphs/heatingsummary.json',
	    {
		month: month,
		year: year,
		set_id: set_id,
		'home_profile_ids[]': home_profile_ids,
		'thermal_storage_ids[]': thermal_storage_ids
	    },
	    function(data) {
		//console.info( data );
		var chart = new Highcharts.Chart({
		    chart: {
			renderTo: data.year + '.' + data.month + '.3',
			type: 'column'
		    },

		    title: {
			text: 'Heating'
		    },
		    subtitle: {
			text: to_month_name( data.month ) + ' ' + data.year
		    },
		    legend: {
			enabled: false
		    },
		    xAxis: {
			categories: [ 'Heating', 'Heating LS' ]
		    },

		    yAxis: { 
			endOnTick: false,
			min: data.min_y,
			labels: {
			    enabled: true
			},
			title: {
			    text: 'kWh'
			}
		    },
		    series: [ {
			data: [data.total_kw_required_for_heating,
			       data.total_kw_required_for_heating_ls ]

		    }
			    ]
		});
	    }
	);


	$.get(
	    'graphs/demand.json',
	    {
		month: month,
		year: year,
		set_id: set_id,
		'home_profile_ids[]': home_profile_ids,
		'thermal_storage_ids[]': thermal_storage_ids
	    },
	    function(data) {
		//console.info( data );
		var chart = new Highcharts.Chart({
		    chart: {
			renderTo: data.year + '.' + data.month + '.2',
			type: 'areaspline'
		    },

		    title: {
			text: 'Demand'
		    },
		    subtitle: {
			text: to_month_name( data.month ) + ' ' + data.year
		    },
		    legend: {
			enabled: false
		    },
		    xAxis: {
			//categories: [ 'Hour Count' ],
			labels : {
			    step: 50,
			    rotation: 90
			}
		    },

		    yAxis: { 
			endOnTick: false,
			labels: {
			    enabled: false
			},
			title: {
			    text: '% Demand',
			    max: 10
			}
		    },
		    series: [ {
			data: data.series
		    }
			    ]
		});
	    }
	);


	$.get(
	    'graphs/generation.json',
	    {
		month: month,
		year: year,
		set_id: set_id,
		'home_profile_ids[]': home_profile_ids,
		'thermal_storage_ids[]': thermal_storage_ids
	    },
	    function(data) {
		//console.info( data );
		var chart = new Highcharts.Chart({
		    chart: {
			renderTo: data.year + '.' + data.month + '.1',
			type: 'areaspline'
		    },

		    title: {
			text: 'Generation'
		    },
		    subtitle: {
			text: to_month_name( data.month ) + ' ' + data.year
		    },
		    legend: {
			enabled: false
		    },
		    xAxis: {
			categories: [ 'Hour Count' ],
			labels : {
			    step: 50,
			    rotation: 90
			}
		    },

		    yAxis: { 
			endOnTick: false,
			labels: {
			    enabled: false
			},
			title: {
			    text: '% Generation',
			    max: 10
			}
		    },
		    series: [ {
			data: data.series
		    }
			    ]
		});
	    }
	);


    });




    // var chart = new Highcharts.Chart({
    // 	    chart: {
    // 		renderTo: 'january-chart',
    // 		type: 'areaspline'
    // 	    },

    // 	    title: {
    // 		text: 'Test Chart'
    // 	    },

    // 	    xAxis: {
    // 		categories: [ 'Apples', 'Bannanas', 'Oranges' ]
    // 	    },

    // 	    yAxis: { 
    // 		title: {
    // 		    text: 'Fruit Eaten'
    // 		}
    // 	    },
    // 	    series: [ {
    // 		    name: 'Jane',
    // 		    data: [1,0,4]
    // 		},    {
    // 		    name: 'John',
    // 		    data: [5,7,3]
    // 		}
    // 		]
    // 	});

}