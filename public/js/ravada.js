

    angular.module("ravada.app",['ngResource','ngSanitize'])
            //.directive("solShowSupportform", swSupForm)
            .directive("solShowNewmachine", swNewMach)
            .directive("solShowListmachines", swListMach)
	        .directive("solShowListusers", swListUsers)
            .directive("solShowCardsmachines", swCardsMach)
            .directive("solShowMachinesNotifications", swMachNotif)
            .directive("solShowMessages", swMess)
	        .service("listUsers", gtListUsers)
            .service("Machine", svcMachine)
            .service("PingBE", svcPingBE)
            .service("AsRead", svcAsRead)
            .service("ReadAll", svcReadAll)
            .service("ListBases", svcListBases)
            .service("ListBasesA", svcListBasesA)
            .service("ListMach", svcListMach)
            .service("ListMessgaes", svcListMessages)
            .controller("new_machine", newMachineCtrl)
            //.controller("SupportForm", suppFormCtrl)
            .controller("machines", machinesCtrl)
            .controller("bases", mainpageCrtl)
            .controller("messages", messagesCrtl)
	        .controller("users", usersCrtl)
            


////////////////////////
///////Directives///////
////////////////////////

    /*function swSupForm() {

        return {
            restrict: "E",
            templateUrl: '/templates/support_form.html',
        };

    };*/

    function swNewMach() {

        return {
            restrict: "E",
            templateUrl: '/templates/new_machine.html',
        };

    };

    function swListMach() {

        return {
            restrict: "E",
            templateUrl: '/templates/list_machines.html',
        };

    };

    function swCardsMach() {

        $url =  '/templates/user_machines.html';
        if ( typeof $_anonymous !== 'undefined' && $_anonymous ) {
            $url =  '/templates/user_machines_anonymous.html';
        }

        return {
            restrict: "E",
            templateUrl: $url,
        };

    };

    function swMachNotif() {
        return {
            restrict: "E",
            templateUrl: '/templates/machines_notif.html',
        };
    };

    function swListUsers() {

        return {
            restrict: "E",
            templateUrl: '/templates/list_users.html',
        };
    };

    function swMess() {
        return {
            restrict: "E",
            templateUrl: '/templates/list_messages.html',
        };
    };

    

////////////////////////////
//////////SERVICES//////////
////////////////////////////


    function svcMachine ( $resource ){

        return $resource('/machine/:action/:id.json',{id:'@id',action:'@action'},{
            shutdown: {
                method:'GET',
                params:{
                    action:'shutdown'
                }
            },

            screenshot: {
                method:'GET',
                params:{
                    action:'screenshot'
                }
            },

            pause: {
                method:'GET',
                params:{
                    action:'pause'
                }
            },

            resume: {
                method:'GET',
                params:{
                    action:'resume'
                }
            },

            start: {
                method:'GET',
                params:{
                    action:'start'
                }
            },

            prepare: {
                method:'GET',
                params:{
                    action:'prepare'
                }
            },

            removeb: {
                method:'GET',
                params:{
                    action:'remove_b'
                }
            }

        });
    };

    function svcAsRead ( $resource ){
        return $resource('/messages/read/:id.json',{id:'@id'});
    };

    function svcReadAll ( $resource ){
        return $resource('/messages/readall.html');
    };

    function svcPingBE ( $resource ){
        return $resource('/pingbackend.json');
    };

    function svcListBases($resource){

        return $resource('/list_bases.json',{},{
            get:{isArray:true}
        });

    };

    function svcListBasesA($resource){

        return $resource('/list_bases_anonymous.json',{},{
            get:{isArray:true}
        });

    };

    function svcListMach($resource){

        return $resource('/list_machines.json',{},{
            get:{isArray:true}
        });

    };

    function svcListMessages($resource){

        return $resource('/messages.json',{},{
            get:{isArray:true}
        });

    };

    function gtListUsers($resource){

        return $resource('/list_users.json',{},{
            get:{isArray:true}
        });

    };

    



////////////////////////
///////Controlers///////
////////////////////////
    
    function newMachineCtrl($scope, $http) {

        $http.get('/list_images.json').then(function(response) {
                $scope.images = response.data;
        });
        $http.get('/list_vm_types.json').then(function(response) {
                $scope.backends = response.data;
        });
        $http.get('/list_lxc_templates.json').then(function(response) {
                $scope.templates_lxc = response.data;
        });


    };


    /*function suppFormCtrl($scope){
        this.user = {};
        $scope.showErr = false;
        $scope.isOkey = function() {
            if($scope.contactForm.$valid){
                $scope.showErr = false;
            } else{
                $scope.showErr = true;
            }
        }

    };*/

    function machinesCtrl($scope, $http, Machine, PingBE, ListMach) {

        
        //if ( typeof $_anonymous !== 'undefined' && $_anonymous ) {
        //    $url_list = "/list_bases_anonymous.json";
        //}

        function ChangeState(id, state) {
            for (i=0; i < $scope.list_machines.length; i++) {
                if ( $scope.list_machines[i].id == id ) {
                    $scope.list_machines[i].is_active = state;
                }
            }
        }
        $scope.reload = function() {
            if ( typeof $_anonymous !== 'undefined' && $_anonymous ) {
                $scope.list_machines = ListMach.get();
            }
            else{
                $scope.list_machines = ListMach.get(function(data) {
                    var spin = {};
                    for(i=0; i < data.length; i++ ) {
                        spin[data.id] = 0;
                    }
                    $scope.onSpin = spin;
                });
            }
            
            $scope.pingbe_fail = PingBE.get();
        };

        $scope.reload();

        $scope.shutdown = function(id) {
            $scope.onSpin[id] = Machine.shutdown({ id: id}, function() {
                ChangeState(id, 0);
            });
        };

        $scope.prepare = function(id) {
            Machine.prepare({ id: id});
        };

        $scope.screenshot = function(id) {
            Machine.screenshot({ id: id});
        };

        $scope.pause = function(id) {
            Machine.pause({ id: id});
        };

        $scope.resume = function(id) {
            Machine.resume({ id: id});
        };

        $scope.start = function(id) {
            Machine.start({ id: id}, function() {
                ChangeState(id, 1);
            });
        };

        $scope.removeb = function(id) {
            Machine.removeb({ id: id});
        };

    };


    function mainpageCrtl($scope, $http, listMach) {

        $url_list = "/list_bases.json";
        if ( typeof $_anonymous !== 'undefined' && $_anonymous ) {
            $url_list = "/list_bases_anonymous.json";
        }
        $http.get($url_list).then(function(response) {
                $scope.list_bases= response.data;
        });

        $http.get('/pingbackend.json').then(function(response) {
            $scope.pingbe_fail = !response.data;

        });

    };

    function messagesCrtl($scope, $http) {

        $http.get('/messages.json').then(function(response) {
                $scope.list_message= response.data;
        });

        $scope.asRead = function(messId){
            var toGet = '/messages/read/'+messId+'.json';
            $http.get(toGet);
        };
        $http.get('/pingbackend.json').then(function(response) {
            $scope.pingbe = response.data;
        });
    };

    function usersCrtl($scope, $http, listUsers) {

        $http.get('/list_users.json').then(function(response) {
                $scope.list_users= response.data;
        });

        $scope.make_admin = function(id) {
            $http.get('/users/make_admin/' + id + '.json')
            location.reload();
        };

        $scope.remove_admin = function(id) {
            $http.get('/users/remove_admin/' + id + '.json')
            location.reload();
        };

        $scope.checkbox = [];

        //if it is checked make the user admin, otherwise remove admin
        $scope.stateChanged = function(id,userid) {
           if($scope.checkbox[id]) { //if it is checked
                $http.get('/users/make_admin/' + userid + '.json')
                location.reload();
           }
           else {
                $http.get('/users/remove_admin/' + userid + '.json')
                location.reload();
           }
        };

    };



