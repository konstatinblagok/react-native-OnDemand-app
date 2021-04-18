angular.module('handyforall.dashboard').controller('DashboardCtrl', DashboardCtrl);

DashboardCtrl.$inject = ['UsersService', 'toastr', 'TasksService', 'TaskersService', 'userCountServiceResolve', 'getRecentUsersResolve', 'getRecentTaskersResolve', 'getRecentTasksResolve', 'DashboardService', '$scope', '$modal', '$state', '$stateParams', 'TasksServiceResolve', 'earningsServiceResolve', '$filter', '$rootScope'];

function DashboardCtrl(UsersService, toastr, TasksService, TaskersService, userCountServiceResolve, getRecentUsersResolve, getRecentTaskersResolve, getRecentTasksResolve, DashboardService, $scope, $modal, $state, $stateParams, TasksServiceResolve, earningsServiceResolve, $filter, $rootScope) {

    var dlc = this;
    dlc.tasks = getRecentTasksResolve[0];
    dlc.users = userCountServiceResolve[0];
    dlc.taskers = getRecentTaskersResolve[0];
    dlc.permission = $scope.privileges.filter(function (menu) {
        return (menu.alias === "users");
    }).map(function (menu) {
        return menu.status;
    })[0];

    dlc.taskerpermission = $scope.privileges.filter(function (menu) {
        return (menu.alias === "tasker");
    }).map(function (menu) {
        return menu.status;

    })[0];

    dlc.taskpermission = $scope.privileges.filter(function (menu) {
        return (menu.alias === "tasks");
    }).map(function (menu) {
        return menu.status;
    })[0];

    var layout = [
        {
            name: 'Booking ID',
            variable: 'booking_id',
            template: '{{content.booking_id}}',
            sort: 1
        },
        {
            name: 'Task Date',
            variable: 'task_date',
            template: '{{content.task_date}}',
            sort: 1
        },
        {
            name: 'Username',
            variable: 'username',
            template: '{{content.user[0].username}}',
            sort: 1
        },
        {
            name: 'Status ',
            template: '<span ng-switch="content.status">' +
            '<span  ng-switch-when="0">Delete</span>' +
            '<span  ng-switch-when="1">Onprogress</span>' +
            '<span  ng-switch-when="3">Accepted</span>' +
            '<span  ng-switch-when="4">StartOff</span>' +
            '<span  ng-switch-when="5">Arrived</span>' +
            '<span  ng-switch-when="6">Completed</span>' +
            '<span  ng-switch-when="7">Completed</span>' +
            '<span  ng-switch-when="8">Cancelled</span>' +
            '<span  ng-switch-when="9">Dispute</span>' +
            '<span  ng-switch-when="10">Search</span>' +
            '</span>'

        },
    ];

    dlc.table = {};
    dlc.table.layout = layout;
    dlc.table.data = getRecentTasksResolve[0];
    dlc.table.count = getRecentTasksResolve[1] || 0;
    dlc.table.delete = {
        service: '/slider/deletebanner', getData: function (currentPage, itemsPerPage, sort, status, search) {
            var skip = (parseInt(currentPage) - 1) * itemsPerPage;
            DashboardService.getRecentTasks(itemsPerPage, skip, sort, status, search).then(function (respo) {
                dlc.table.data = respo[0];
                dlc.table.count = respo[1];
            });
        }
    };

    $scope.refMonth = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    $scope.monthArrayObj = [[1, 'JAN'], [2, 'FEB'], [3, 'MAR'], [4, 'APR'], [5, 'MAY'], [6, 'JUN'], [7, 'JUL'], [8, 'AUG'], [9, 'SEP'], [10, 'OCT'], [11, 'NOV'], [12, 'DEC']];

    $scope.currentMonth = new Date().getMonth() + 1;
    $scope.newMonthArray = [];
    for (var i = 0, k = $scope.currentMonth; i < $scope.monthArrayObj.length; i++ , k++) {
        if (k >= $scope.refMonth.length) {
            $scope.monthArrayObj[i][1] = $scope.refMonth[i - ($scope.refMonth.length - $scope.currentMonth)];
        } else {
            $scope.monthArrayObj[i][1] = $scope.refMonth[k];
        }
    }

    $scope.convertedData = {
        orderCount: [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [8, 0], [9, 0], [10, 0], [11, 0], [12, 0]],
        orderAmount: [[1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0], [8, 0], [9, 0], [10, 0], [11, 0], [12, 0]],
        monthArray: []
    };

    UsersService.getAllUsers(0, 10, 0).then(function (data) {
        if (data[2]) {
            $scope.userlist = data[2].allValue || 0;
        }
        else {
            $scope.userlist = 0;
        }
    });

    DashboardService.getRecentUsers().then(function (data) {
        $scope.RecentUsers = data;
    });


    /*    DashboardService.dashboardDetasils().then(function (data) {
         console.log(data);
       }); */

    DashboardService.getTaskDetails().then(function (data) {
        $scope.taskDetails = data;
    });

    DashboardService.getTaskerDetails().then(function (data) {
        $scope.taskersDetails = data;
    });

    DashboardService.getverifiedTaskerDetails().then(function (data) {
        $scope.verifiedtaskersDetails = data;
    });

    DashboardService.getTaskers().then(function (data) {
        $scope.taskers = data[1];
    });


    if (TasksServiceResolve) {
        $scope.tasks = TasksServiceResolve[0].length || 0;
    }

    DashboardService.getCategoryList().then(function (data) {
        $scope.categorylist = data[1];
    });

    DashboardService.getAllearnings().then(function (data) {
        $scope.earnings = (data.data[0]).toFixed(2);
        $scope.earningsadmin = (data.data[1]).toFixed(2);
        $scope.coupons = data.data[2];
        $scope.subscriber = data.data[3];
    });

    dlc.updateuser = function () {
        DashboardService.getRecentUsers().then(function (data) {
            $scope.RecentUsers = data;
        });
    }

    dlc.approvtaskerss = function () {
        DashboardService.getTaskerDetails().then(function (data) {
            $scope.taskersDetails = data;
        });
    }

    DashboardService.getdefaultcurrency().then(function (data) {
        $scope.getdefaultcurrency = data;



        $scope.datasetStat = [{
            data: $scope.convertedData.orderAmount,
            label: 'Order Sale Amount',
            bars: {
                show: true,
                barWidth: 0.6,
                lineWidth: 0,
                fillColor: { colors: [{ opacity: 0.3 }, { opacity: 0.8 }] }
            }
        }, {
            data: $scope.convertedData.orderCount,
            label: 'Dispute Amount',
            points: {
                show: true,
                radius: 6
            },
            splines: {
                show: true,
                tension: 0.45,
                lineWidth: 5,
                fill: 0
            }
        }];
        $scope.optionsStat = {
            colors: ['#e05d6f', '#61c8b8'],
            series: {
                shadowSize: 0
            },
            legend: {
                backgroundOpacity: 0,
                margin: -7,
                position: 'ne',
                noColumns: 2
            },
            xaxis: {
                tickLength: 0,
                font: {
                    color: '#fff'
                },
                position: 'bottom',
                ticks: $scope.monthArrayObj
            },
            yaxis: {
                tickLength: 0,
                font: {
                    color: '#fff'
                },
                position: 'left',
                ticks: [1000, 2000, 3000, 4000, 5000]
            },
            grid: {
                borderWidth: {
                    top: 0,
                    right: 0,
                    bottom: 1,
                    left: 1
                },
                borderColor: 'rgba(255,255,255,.3)',
                margin: 0,
                minBorderMargin: 0,
                labelMargin: 20,
                hoverable: true,
                clickable: true,
                mouseActiveRadius: 6
            },
            tooltip: true,
            tooltipOpts: {
                content: '%s: %y',
                defaultTheme: true,
                shifts: {
                    x: 0,
                    y: 20
                }
            }
        };


        /*[200,400,600,800,1000,1200,1400]*/
        $scope.dataset = [];
        $scope.options = {
            series: {
                pie: {
                    show: true,
                    innerRadius: 0,
                    stroke: {
                        width: 0
                    },
                    label: {
                        show: true,
                        threshold: 0.05
                    }
                }
            },
            colors: ['#428bca', '#5cb85c', '#f0ad4e', '#d9534f', '#5bc0de', '#616f77'],
            grid: {
                hoverable: true,
                clickable: true,
                borderWidth: 0,
                color: '#ccc'
            },
            tooltip: true,
            tooltipOpts: { content: '%s: %p.0%' }
        };

        dlc.deleteuser = function (id) {
            var modalInstance = $modal.open({
                animation: true,
                templateUrl: 'app/admin/modules/dashboard/views/deleteuser.modal.tab.html',
                controller: 'DeleteUserModalInstanceCtrl',
                controllerAs: 'DCMIC',
                resolve: {
                    user: function () {
                        return id;
                    }
                }
            });
            modalInstance.result.then(function (id) {
                DashboardService.deleteUser(id).then(function (response) {
                    if (response.code == 11000) {
                        toastr.error('Error');
                    }
                    else {
                        dlc.updateuser();
                        toastr.success('success', 'Deleted Successfully');

                    }

                });
            });
        }
        dlc.approvtasker = function (id, status) {
            DashboardService.approvTasker(id, status).then(function (response) {
                if (response.code == 11000) {
                    toastr.error('Error');
                }
                else {
                    if (response.data.status == 1) {
                        dlc.approvtaskerss();
                        toastr.success('success', 'Approved Successfully');
                    }
                    else if (response.data.status == 2) {
                        dlc.approvtaskerss();
                        toastr.success('success', 'UnPublish Successfully');
                    }

                }
            });
        }
        dlc.edit = function (taskerid) {
            $state.go('app.taskers.edit', ({ id: taskerid }));
        }
        dlc.edituser = function (userid) {
            $state.go('app.users.add', ({ id: userid }));
        }
        dlc.viewtask = function (taskid) {
            $state.go('app.tasks.add', ({ id: taskid }));
        }

        $scope.earningsDetails = earningsServiceResolve;
        $scope.adminlist = [];
        $scope.taskslist = [];
        $scope.xaxis_list = [];
        var i = 12;
        var costLine = $scope.earningsDetails.response.earnings.filter(function (admin) {
            $scope.adminlist.push([i, admin.admin_earnings]);
            $scope.taskslist.push([i, admin.amount]);
            $scope.xaxis_list.push([i, admin.month]);
            i--;
            return admin;
        })

        $scope.dataset = [{
            data: $scope.adminlist,
            label: 'Admin Earnings',
            points: {
                show: true, // points
                radius: 6
            },
            splines: {
                show: true,
                lineWidth: 3,
                tension: 0.001,
                fill: 0
            }
        }, {
            data: $scope.taskslist,
            label: 'Total task Amount',
            points: {
                show: true,
                radius: 6
            },
            splines: {
                show: true,
                tension: 0.001,
                lineWidth: 3,
                fill: 0
            }
        },
        {
            visible: $rootScope.earningsVisiblevalue
        }];

        $scope.options = {
            colors: ['#004687', '#BCCF02'],
            series: {
                shadowSize: 0
            },
            xaxis: {
                font: {
                    color: '#ccc'
                },
                position: 'bottom',
                ticks: $scope.xaxis_list
            },
            yaxis: {
                font: {
                    color: '#ccc'
                },
                tickFormatter: function (v, axis) {
                    if (v % 10 == 0) {
                        return $scope.getdefaultcurrency.symbol + v;
                    } else {
                        return "";
                    }
                },
            },
            grid: {
                hoverable: true,
                clickable: true,
                borderWidth: 0,
                color: '#ccc'
            },
            tooltip: true,
            tooltipOpts: {
                content: '%s.: %y.4',
                defaultTheme: false,
                shifts: {
                    x: 0,
                    y: 20
                }
            }
        };
    });
}

angular.module('handyforall.taskers').controller('DeleteUserModalInstanceCtrl', function ($modalInstance, user) {
    var dcmic = this;
    dcmic.userid = user;
    dcmic.ok = function () {
        $modalInstance.close(dcmic.userid);
    };
    dcmic.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});
