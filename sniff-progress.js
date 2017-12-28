// Copyright 2015, EMC, Inc.

'use strict';

var di = require('di'),
    core = require('on-core')(di),
    injector = new di.Injector(
        core.injectables
    ),
    messenger = injector.get('Services.Messenger'),
    assert = injector.get('Assert');

var args = process.argv.slice(2);

try {
    assert.string(args[0], "AMQP Exchange");
    assert.string(args[1], "AMQP RoutingKey");
} catch (e) {
    console.log(e);
    process.exit(1);
}

messenger.start().then(function () {
    messenger.subscribe(args[0], args[1], function (event, data) {
        console.log('####################################################');
        //console.log(data.deliveryInfo.routingKey);
        var percentage = event.data.progress.percentage;
        console.log('========> os installl progress <=======:', percentage);
        console.log('####################################################');
        console.log(JSON.stringify(event, null, '  '));
        if ( percentage === "100%" ){
            console.log('INFO: OS install successfully.');
            process.exit(0);
        }
    }
    //console.log("when to execute.");
    //throw new Error('is it work?');
    ).done();
}).catch(function (error) {
    console.log('ERROR:', error);
});
