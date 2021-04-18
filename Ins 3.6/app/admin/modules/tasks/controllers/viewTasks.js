angular.module('handyforall.tasks').controller('viewTasksCtrl', viewTasksCtrl);

viewTasksCtrl.$inject = ['TasksServiceResolve', 'TasksService', '$scope', 'toastr','$rootScope'];

function viewTasksCtrl(TasksServiceResolve, TasksService, $scope, toastr, $rootScope) {

    var tlc = this;
    tlc.permission = $scope.privileges.filter(function (menu) {
        return (menu.alias === "tasks");
    }).map(function (menu) {
        return menu.status;
    })[0];

    if (TasksServiceResolve[2]) {
        tlc.allValue = TasksServiceResolve[2].allValue || 0;
        tlc.onGoingValue = TasksServiceResolve[2].onGoingValue || 0;
        tlc.comlpleteValue = TasksServiceResolve[2].completedValue || 0;
        tlc.cancellValue = TasksServiceResolve[2].cancelValue || 0;
    }

    $scope.statusValue = 0;
    tlc.statusPass = function statusPass(status, limit, skip) {
        $scope.statusValue = status;
        if (status == 1 || status == 7 || status == 8 || status == 0) {
            TasksService.getTasksList(status, limit, skip).then(function (respo) {
                tlc.table.data = respo[0];
                tlc.table.count = respo[1] || 0;
                if (respo[2]) {
                    tlc.allValue = respo[2].allValue || 0;
                    tlc.onGoingValue = respo[2].onGoingValue || 0;
                    tlc.comlpleteValue = respo[2].completedValue || 0;
                    tlc.cancellValue = respo[2].cancelValue || 0;
                }
            });
        }
    };

    TasksService.getSettings().then(function (response) {
        tlc.getsetting = response;
    });

    tlc.exportTask = function exportTask() {
        TasksService.exportData().then(function (response) {
            if (response.error) {
                toastr.error('No data found to export');
            } else {
                window.location.href = tlc.getsetting.site_url + "tools/taskexport";
            }
        }, function (err) {
            toastr.error(err);
        });
    }

    var layout = [
        {
            name: 'Task ID',
            template: '{{content.booking_id}}',
        },
        {
            name: 'Task Category',
            template: '{{content.category[0].name}}',
            sort: 1,
            variable: 'category'
        },
        {
            name: $rootScope.user,
            template: '{{content.user[0].username}}'
        },
        {
            name: $rootScope.tasker,
            template: '{{content.tasker[0].username}}'

        },
        {
            name: 'Status ',
            template:
            '<div ng-if="content.status==0">Delete</div>' +
            '<div ng-if="content.status==1">Onprogress </div>' +
            '<div ng-if="content.status==2">Accepted </div>' +
            '<div ng-if="content.status==3">StartOff </div>' +
            '<div ng-if="content.status==4">Arrived </div>' +
            '<div ng-if="content.status==5">StartJob </div>' +
            '<div ng-if="content.status==6">Payment Pending</div>' +
            '<div ng-if="content.status==7">Completed</div>' +
            '<div ng-if="content.status==8">Cancelled</div>' +
            '<div ng-if="content.status==9">Dispute</div>' +
            '<div ng-if="content.status==10">Search</div>' +
            '<div ng-if="content.status==11">Expired</div>'
        },
        {
            name: 'Actions',
            template: '<button class="btn btn-info btn-rounded btn-ef btn-ef-5 btn-ef-5b" ng-if="options.permission.edit != false" ui-sref=app.tasks.add({action:"edit",id:content._id})><i class="fa fa-eye"></i> <span>View</span></button>' +
            '<button class="btn btn-danger btn-rounded btn-ef btn-ef-5 btn-ef-5b" ng-if="options.permission.delete != false" ng-click="CCC.openDeleteModal(small, content, options)" ><i class="fa fa-trash"></i> <span>Delete</span></button>'
        }
    ];

    tlc.table = {};
    tlc.table.layout = layout;
    tlc.table.data = TasksServiceResolve[0];
    tlc.table.count = TasksServiceResolve[1] || 0;
    tlc.table.delete = {
        'permission': tlc.permission, service: '/tasks/deletequestion', getData: function (currentPage, itemsPerPage, sort, status, search) {
            var skip = (parseInt(currentPage) - 1) * itemsPerPage;
            TasksService.getTasksList($scope.statusValue, itemsPerPage, skip, sort, status, search).then(function (respo) {
                tlc.table.data = respo[0];
                tlc.table.count = respo[1];
            });
        }
    };

}
