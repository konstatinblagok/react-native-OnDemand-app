angular.module('handyforall.taskers').controller('addNewTaskerCtrl', addNewTaskerCtrl);

addNewTaskerCtrl.$inject = ['$filter', '$state', '$scope', '$modal', 'toastr', '$timeout', 'TaskersService', 'taskerAddServiceResolve', 'CategoryServiceResolve', 'NgMap'];

function addNewTaskerCtrl($filter, $state, $scope, $modal, toastr, $timeout, TaskersService, taskerAddServiceResolve, CategoryServiceResolve, NgMap) {

    $scope.render = false;

    var antsc = this;
    if (antsc.tasker === 'undefined') {
        antsc.tasker = taskerAddServiceResolve[0];
    }
	
	antsc.radiusby = $scope.gensettings.distanceby
	if(antsc.radiusby == 'km'){
		antsc.radiusval = 1000;
	}
	else{
		antsc.radiusval = 1609.34;
	}

    antsc.tasker = {
        birthdate: { year: '', month: '', date: '' },
        location: '',
        working_area: [],
        phone: {}
    }
    antsc.tasker.imageFile = [];
    antsc.dateChange = function () {
        antsc.tasker.birthdate.year = antsc.dob.getFullYear();
        antsc.tasker.birthdate.month = antsc.dob.getMonth() + 1;
        antsc.tasker.birthdate.date = antsc.dob.getDate();

        if (calculate_age(antsc.tasker.birthdate.month, antsc.tasker.birthdate.date, antsc.tasker.birthdate.year, antsc.dob)) {
            antsc.tasker.birthdate.year = antsc.dob.getFullYear();
            antsc.tasker.birthdate.month = antsc.dob.getMonth() + 1;
            antsc.tasker.birthdate.date = antsc.dob.getDate();
            antsc.tasker.dob = antsc.dob;
        } else {
            toastr.error('Your age should be 18+');
        }
    };
    antsc.tasker.location = {};
    $scope.maps = [];
    $scope.$on('mapInitialized', function (evt, evtMap) {
        $scope.maps.push(evtMap);
    });
    $scope.visibleValue = false;
    $scope.showImage = false;
    // Croping
    $scope.myImage = '';
    antsc.myCroppedImage = '';
    $scope.imageChangeValue = false;
    // $scope.cropType = 'circle'; // circle & square
    $scope.handleFileSelect = function (evt) {
        $scope.imageChangeValue = true;
        $scope.avatar_image_previous_value = evt;
        $scope.visibleValue = true;
        var file = evt.currentTarget.files[0];
        var reader = new FileReader();
        reader.onload = function (evt) {
            $scope.$apply(function ($scope) {
                $scope.myImage = evt.target.result;
            });
        };
        reader.readAsDataURL(file);
    };
    // End Croping


    antsc.previousAvatarPage = function (steps) {
        $scope.steps.step1 = true;
        //$scope.handleFileSelect($scope.avatar_image_previous_value);
    };

    antsc.addNewCategory = function addNewCategory(steps) {
        $scope.steps.step5 = true;
        antsc.tasker.radius = 50;
        if (!antsc.taskerareaaddress) {
            navigator.geolocation.getCurrentPosition(function (pos) {
                var latlng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
                var geocoder = geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                    if (status == google.maps.GeocoderStatus.OK) {
                        if (results[1]) {
                            antsc.tasker.availability_address = results[1].formatted_address;
                            antsc.taskerareaaddress = results[1].formatted_address;
                        }
                    }
                })
                antsc.tasker.location.lng = pos.coords.longitude;
                antsc.tasker.location.lat = pos.coords.latitude;
            })
        }
        $timeout(function () {
            google.maps.event.trigger($scope.maps[0], 'resize');
            $scope.maps[0].setCenter(new google.maps.LatLng(antsc.tasker.location.lat, antsc.tasker.location.lng));
        }, 100);
    }

    /*   antsc.tasker.location.lat = pos.coords.latitude;
                  })
              }
              if (!antsc.tasker.availability_address) {
                $timeout(function () {
                    google.maps.event.trigger($scope.maps[0], 'resize');
                    $scope.maps[0].setCenter(new google.maps.LatLng(antsc.tasker.location.lat, antsc.tasker.location.lng));
                }, 100);
              }


          }*/
    function calculate_age(birth_month, birth_day, birth_year, dobdate) {
        console.log("birth_month, birth_day, birth_year, dobdate",birth_month, birth_day, birth_year, dobdate);
        var names = dobdate.getDate();
        var month = dobdate.getMonth() + 1;
        var year = dobdate.getFullYear();
        var date = new Date();
        var currentDate = date.getDate();
        var currentMonth = date.getMonth() + 1;
        var conditionyear = date.getFullYear() - 18;
        if (conditionyear == year) {
            if (month <= currentMonth) {
                if (names <= currentDate) {
                    return true;
                } else {
                    //  toastr.error("Tasker Age must be above 18!");
                    return false;

                }
            } else {
                //  toastr.error("Tasker Age must be above 18!");
                return false;
            }

        } else if (conditionyear < year) {
            //toastr.error("Tasker Age must be above 18!");
            return false;
        } else if (conditionyear > year) {
            return true;
        }
    }
    $scope.today = function () {
        antsc.dob = new Date();
        antsc.tasker.birthdate.year = antsc.dob.getFullYear();
        antsc.tasker.birthdate.month = antsc.dob.getMonth() + 1;
        antsc.tasker.birthdate.date = antsc.dob.getDate();
    };

    $scope.today = function () {
        $scope.dt = new Date();
    };

    $scope.today();

    $scope.toggleMin = function () {
        $scope.minDate = $scope.minDate ? null : new Date();
    };
    $scope.toggleMin();

    $scope.status = {
        opened: false
    };

    $scope.open = function ($event) {
        $scope.status.opened = true;
    };


    $scope.dateOptions = {
        formatYear: 'yy',
        startingDay: 1,
        'class': 'datepicker'
    };

    $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
    $scope.format = $scope.formats[0];


    TaskersService.getQuestion().then(function (respo) {
        antsc.getQuestion = respo;
    });

    antsc.availability = {};

    /*antsc.availability.days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    antsc.workingDays = [{ day: "Sunday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }, { day: "Monday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }, { day: "Tuesday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }, { day: "Wednesday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }, { day: "Thursday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }, { day: "Friday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }, { day: "Saturday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }];*/

    var workingDays = [{ day: "Sunday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Monday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Tuesday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Wednesday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Thursday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Friday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Saturday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }];

    var workingTimes = {};
    workingTimes.morning = {
        from: moment.tz(new Date(99, 5, 24, 8, 0, 0, 0), $scope.date.timezone).format($scope.date.time_format),
        to: moment.tz(new Date(99, 5, 24, 12, 0, 0, 0), $scope.date.timezone).format($scope.date.time_format)
    };
    workingTimes.afternoon = {
        from: moment.tz(new Date(99, 5, 24, 12, 0, 0, 0), $scope.date.timezone).format($scope.date.time_format),
        to: moment.tz(new Date(99, 5, 24, 16, 0, 0, 0), $scope.date.timezone).format($scope.date.time_format)
    };
    workingTimes.evening = {
        from: moment.tz(new Date(99, 5, 24, 16, 0, 0, 0), $scope.date.timezone).format($scope.date.time_format),
        to: moment.tz(new Date(99, 5, 24, 20, 0, 0, 0), $scope.date.timezone).format($scope.date.time_format)
    };
    antsc.workingDays = workingDays;
    var DaysData = [{ Morning: "MORNING", afternoon: "AFTERNOON", evening: "EVENING", Save: "SAVE" }];
    antsc.tasker.working_days = antsc.workingDays;

    angular.forEach(antsc.workingDays, function (workingDays, key) {
        angular.forEach(antsc.tasker.working_days, function (UserWorkingdays) {
            if (UserWorkingdays.day == workingDays.day) {
                antsc.workingDays[key] = UserWorkingdays;
            }
        })
    })

    antsc.taskerareaChanged = function () {
        antsc.taskerPlace = this.getPlace();
        antsc.tasker.location.lng = antsc.taskerPlace.geometry.location.lng();
        antsc.tasker.location.lat = antsc.taskerPlace.geometry.location.lat();
        if (typeof antsc.taskerPlace.geometry.location.lng() != 'undefined' && typeof antsc.taskerPlace.geometry.location.lat() != 'undefined') {
            var locationa = antsc.taskerPlace;
            var dummy = locationa.address_components.filter(function (value) {
                return value.types[0] == "sublocality_level_1";
            }).map(function (data) {
                return data;
            });
            antsc.dummyAddress = dummy.length;
        } else {
            toastr.error('Invalid Location')
        }

    }
    var i = 0;
    antsc.mapToInput = function (event) {

        if ($scope.maps[0]) {
            antsc.tasker.radius = parseInt($scope.maps[0].shapes.circle.radius / antsc.radiusval);
            var lat = $scope.maps[0].shapes.circle.center.lat();
            var lng = $scope.maps[0].shapes.circle.center.lng();
            var latlng = new google.maps.LatLng(lat, lng);
            var geocoder = geocoder = new google.maps.Geocoder();
            geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                if (status == 'OK') {
                    $scope.$apply(function () {
                        if (i > 0) {
                            antsc.taskerPlace = {};
                        }
                        i + 1;
                        antsc.tasker.availability_address = results[0].formatted_address;
                        antsc.taskerareaaddress = results[0].formatted_address;
                        antsc.temp_taskerareaaddress = results[0].formatted_address;
                        antsc.tasker.location = {};
                        antsc.tasker.location.lng = lng;
                        antsc.tasker.location.lat = lat;
                    });
                }
            });
        }
    }

    $scope.today();
    antsc.availabilityModal = function (size, index) {
        var modalInstance = $modal.open({
            animation: true,
            backdrop: 'static',
            keyboard: false,
            templateUrl: 'app/admin/modules/taskers/views/availability.modal.tab.html',
            controller: 'AvailabilityModalInstanceCtrl',
            //controllerAs: 'AAM',
            resolve: {
                /* data: function () {
                     return { 'day': day, 'days': antsc.availability.days };
                 },
                 workingDays: function () {
                     return antsc.workingDays;
                 }*/
                workingDays: function () {
                    return antsc.tasker.working_days;
                },
                workingTimes: function () {
                    return workingTimes;
                },
                DaysData: function () {
                    return DaysData;
                },
                selectedIndex: function () {
                    return index;
                }
            }
        });
        modalInstance.result.then(function (WorkingDays) {
            //antsc.workingDays[data.index] = data.working_day;
            //antsc.tasker.working_days = $filter('filter')(antsc.workingDays, { "not_working": false });
            antsc.tasker.working_days[index] = WorkingDays;
        }, function () {
        });
    }

    antsc.placeChanged = function () {
        antsc.place = this.getPlace();
        antsc.tasker.location.lng = antsc.place.geometry.location.lng();
        antsc.tasker.location.lat = antsc.place.geometry.location.lat();
        antsc.tasker.availability_address = antsc.place.formatted_address;
        var locationa = antsc.place;
        antsc.tasker.address.line1 = antsc.place.formatted_address;
        antsc.tasker.address.line2 = '';

        if (locationa.name) {
            antsc.tasker.address.line1 = locationa.name;
        }

        for (var i = 0; i < locationa.address_components.length; i++) {
            for (var j = 0; j < locationa.address_components[i].types.length; j++) {
                if (locationa.address_components[i].types[j] == 'neighborhood') {
                    if (antsc.tasker.address.line1 != locationa.address_components[i].long_name) {
                        if (antsc.tasker.address.line1 != '') {
                            antsc.tasker.address.line1 = antsc.tasker.address.line1 + ',' + locationa.address_components[i].long_name;
                        } else {
                            antsc.tasker.address.line1 = locationa.address_components[i].long_name;
                        }
                    }
                }
                if (locationa.address_components[i].types[j] == 'route') {
                    if (antsc.tasker.address.line1 != locationa.address_components[i].long_name) {
                        if (antsc.tasker.address.line2 != '') {
                            antsc.tasker.address.line2 = antsc.tasker.address.line2 + ',' + locationa.address_components[i].long_name;
                        } else {
                            antsc.tasker.address.line2 = locationa.address_components[i].long_name;
                        }
                    }

                }
                if (locationa.address_components[i].types[j] == 'street_number') {
                    if (antsc.tasker.address.line2 != '') {
                        antsc.tasker.address.line2 = antsc.tasker.address.line2 + ',' + locationa.address_components[i].long_name;
                    } else {
                        antsc.tasker.address.line2 = locationa.address_components[i].long_name;
                    }

                }
                if (locationa.address_components[i].types[j] == 'sublocality_level_1') {
                    if (antsc.tasker.address.line2 != '') {
                        antsc.tasker.address.line2 = antsc.tasker.address.line2 + ',' + locationa.address_components[i].long_name;
                    } else {
                        antsc.tasker.address.line2 = locationa.address_components[i].long_name;
                    }

                }
                if (locationa.address_components[i].types[j] == 'locality') {

                    antsc.tasker.address.city = locationa.address_components[i].long_name;
                }
                if (locationa.address_components[i].types[j] == 'country') {

                    antsc.tasker.address.country = locationa.address_components[i].long_name;
                }
                if (locationa.address_components[i].types[j] == 'postal_code') {

                    antsc.tasker.address.zipcode = locationa.address_components[i].long_name;
                }
                if (locationa.address_components[i].types[j] == 'administrative_area_level_1' || locationa.address_components[i].types[j] == 'administrative_area_level_2') {
                    antsc.tasker.address.state = locationa.address_components[i].long_name;
                }
            }
        }
    };


    if (antsc.tasker.working_area.coordinates) {
        antsc.onMapOverlayCompleted = function (e) {
            var arr = [];
            antsc.tasker.working_area = {};
            antsc.tasker.working_area.coordinates = [];
            e.getPath().forEach(function (latLng) { arr.push(latLng.toString()); });
            for (var i = 0; i < arr.length; i++) {
                var latlang = arr[i].replace(/[()]/g, '');
                var latlng = latlang.split(', ');
                antsc.tasker.working_area.coordinates[0].push(latlng);
            }
        };
    }


    antsc.availabilitiesModelOpen = function (size, index) {
        var modalInstance = $modal.open({
            animation: true,
            template: '<div class="availabilities-day-form adminweekmodal" ><div class=""><div class=""><div class="modal-header modal-header-success"><button class="close" type="button" ng-click="cancel()">×</button><h1 class="day-text">{{WorkingDays.day}}</h1></div><div class="modal-body"><ul class="radio-contr"><li><input ng-model ="WorkingDays.hour.morning" id="morning" class="u-hidden" type="checkbox" value="morning" name="windowFields"><label class="switch" for="morning"></label><label for="morning">Morning (8am - 12pm)</label></li><li><input ng-model ="WorkingDays.hour.afternoon" id="evenig" class="u-hidden" type="checkbox" value="morning" name="windowFields"><label class="switch" for="evenig"></label><label for="evenig">Afternoon (12pm - 4pm)</label></li><li><input id="afternoon" ng-model ="WorkingDays.hour.evening" class="u-hidden" type="checkbox" value="morning" name="windowFields"><label class="switch" for="afternoon"></label><label for="afternoon">Evening (4pm - 8pm)</label></li></ul></div><div class="modal-footer"><button type="button" class="btn btn-default pull-left" ng-click="ok()" >Save</button></div></div></div></div>',
            controller: 'ModalInstanceWorkingDayCtrl',
            size: size,
            resolve: {
                WorkingDays: function () {
                    return antsc.tasker.working_days;
                },
                selectedIndex: function () {
                    return index;
                }
            }
        });

        modalInstance.result.then(function (WorkingDays) {
            antsc.tasker.working_days[WorkingDays.selectedIndex] = WorkingDays.WorkingDays;
        }, function (dasd) {
        });
    };

    antsc.working_areas = [];
    antsc.working_areas[0] = [];

    if (antsc.tasker.working_area.coordinates) {
        angular.forEach(antsc.tasker.working_area.coordinates[0], function (value, key) {
            antsc.working_areas[0][key] = [];
            antsc.working_areas[0][key][0] = antsc.tasker.working_area.coordinates[0][key][1];
            antsc.working_areas[0][key][1] = antsc.tasker.working_area.coordinates[0][key][0];

        })
    }

    TaskersService.gettaskercategory(antsc.tasker._id).then(function (respo) {
        antsc.taskercategory = respo;
    });

    TaskersService.getCategories().then(function (respo) {
        antsc.categories = respo;
    });

    TaskersService.getExperience().then(function (respo) {
        antsc.experiences = respo;

    });
    antsc.addnewcat = function () {
        TaskersService.gettaskercategory(antsc.tasker._id).then(function (respo) {
            antsc.taskercategory = respo;
        });
    }
    TaskersService.defaultCurrency().then(function (respo) {
        antsc.defaultCurrency = respo;

    });

    antsc.tasker.taskerskills = [];
    antsc.addnewcategories = [];

    antsc.categoryModal = function (category) {
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: 'app/admin/modules/taskers/views/editcategory.modal.tab.html',
            controller: 'NewCategoriesModalInstanceCtrl',
            controllerAs: 'ACM',
            resolve: {
                experiences: function () {
                    return antsc.experiences;
                },
                user: function () {
                    return antsc.tasker;
                },
                categories: function () {
                    return antsc.categories;
                },
                category: function () {
                    return category;
                },
                defaultCurrency: function () {
                    return antsc.defaultCurrency;
                }
            }
        });

        modalInstance.result.then(function (selectedCategoryData) {
            antsc.tasker.taskerskills.push(selectedCategoryData);
            antsc.tasker.imageFile.push(selectedCategoryData.file);
            antsc.addnewcategories = antsc.categories.filter(function (data) {
                return antsc.tasker.taskerskills.some(function (data2) {
                    return data2.childid == data._id;
                });
            }).map(function (mapdata) {
                return mapdata;
            })
        }, function () { });
    };

    antsc.deletecategoryitem = function (data) {
        angular.forEach(antsc.addnewcategories, function (value, key) {
            if (value._id == data) {
                antsc.addnewcategories.splice(key, 1);
                toastr.success("Category removed from the selected list");
            }
        });
        angular.forEach(antsc.tasker.taskerskills, function (value, key) {
            if (value.childid == data) {
                antsc.tasker.taskerskills.splice(key, 1);
            }
        });

    }

    antsc.deletecategory = function (category) {
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: 'app/admin/modules/taskers/views/deletecategory.modal.tab.html',
            controller: 'DeleteCategoriesModalInstanceCtrl',
            controllerAs: 'DCMIC',
            resolve: {
                user: function () {
                    return antsc.tasker;
                },
                category: function () {
                    return category;
                }
            }

        });
        modalInstance.result.then(function (deletecategorydata) {
            TaskersService.deleteCategory(deletecategorydata).then(function (response) {
                toastr.success('success', 'Updated Successfully');
            }, function () {

            });
        });
    }

    antsc.submitTaskertData = function submitTaskertData(valid, data, steps) {
        console.log("valid", valid);
        antsc.tasker.role = "tasker";
        antsc.tasker.avatar = antsc.myCroppedImage;
        console.log("$scope.imageChangeValue", $scope.imageChangeValue);
        console.log("data.phone.number", data.phone.number);
        if (data.phone.number && data.phone.number != undefined) {
            if ($scope.imageChangeValue == true) {
                if (valid) {
                    if (calculate_age(antsc.tasker.birthdate.month, antsc.tasker.birthdate.date, antsc.tasker.birthdate.year, antsc.dob)) {
                        if (typeof antsc.place != "undefined") {
                            // $scope.steps.step2 = true;
                        } else {
                            antsc.tasker.address.line1 = '';
                            toastr.error('Invalid Address');
                            $scope.imageChangeValue = false;
                        }

                    } else {
                        toastr.error('Your age should be 18+');
                        $scope.imageChangeValue = false;
                    }
                    var sendData = {
                        'phone': data.phone,
                        'email': data.email,
                        'username': data.username
                    };
                    TaskersService.checkphoneno(sendData).then(function (response, err) {
                        console.log("response", response);
                        if (response == "" || response.msg == "Phone Number Already Exists") {
                            toastr.error(response.msg);
                            $scope.imageChangeValue = false;
                        } else if (response.msg == "Username Already Exists") {
                            toastr.error(response.msg);
                            $scope.imageChangeValue = false;
                        } else if (response.msg == "Email Id Already Exists") {
                            toastr.error(response.msg);
                            $scope.imageChangeValue = false;
                        } else if (response.msg == "success") {
                            $scope.steps.step2 = true;
                            $scope.imageChangeValue = false;
                        }
                    }, function (err) {
                        toastr.error(err.msg);
                    });
                }
                else {
                    toastr.error('form is invalid');
                    //$scope.handleFileSelect($scope.avatar_image_previous_value);
                    $scope.imageChangeValue = false;
                }
            } else {
                if (calculate_age(antsc.tasker.birthdate.month, antsc.tasker.birthdate.date, antsc.tasker.birthdate.year, antsc.dob)) {
                    if ((antsc.place == undefined) || (antsc.tasker.email == undefined) || (antsc.tasker.name.first_name == undefined) || (antsc.tasker.name.last_name == undefined) || (antsc.tasker.username == undefined) || (antsc.tasker.gender == undefined) || (antsc.tasker.phone == undefined)) {
                         toastr.error('Form is Invalid');
                         $scope.imageChangeValue = false;
                    } else {
                        //toastr.error('Form is Invalid');
                        var sendData = {
                        'phone': data.phone,
                        'email': data.email,
                        'username': data.username
                    };
                    TaskersService.checkphoneno(sendData).then(function (response, err) {
                        console.log("response", response);
                        if (response == "" || response.msg == "Phone Number Already Exists") {
                            toastr.error(response.msg);
                            $scope.imageChangeValue = false;
                        } else if (response.msg == "Username Already Exists") {
                            toastr.error(response.msg);
                            $scope.imageChangeValue = false;
                        } else if (response.msg == "Email Id Already Exists") {
                            toastr.error(response.msg);
                            $scope.imageChangeValue = false;
                        } else if (response.msg == "success") {
                            $scope.steps.step2 = true;
                            $scope.imageChangeValue = false;
                        }
                    }, function (err) {
                        toastr.error(err.msg);
                    });

                    }

                } else {
                    toastr.error('Your age should be 18+');
                    $scope.imageChangeValue = false;
                }

            }

        } else {
            toastr.error('Please Enter the Mobile Number');
            $scope.imageChangeValue = false;
           
        }
        /* }else{
              toastr.error('Please Enter the all required fields');
         }*/

    };

    antsc.saveNewTaskerPassword = function saveNewTaskerPassword(valid, data, steps) {
        antsc.tasker.role = "tasker";
        if (valid) {
            $scope.steps.step3 = true;
        } else {
            toastr.error('form is invalid');
        }
    };
    TaskersService.getQuestion().then(function (respo) {
        antsc.getQuestion = respo;
    });

    if (antsc.tasker.profile_details) {
        antsc.profileDetails = antsc.tasker.profile_details.reduce(function (total, current) {
            total[current.question] = current.answer;
            return total;
        }, {});
    } else {
        antsc.profileDetails = [];
        antsc.tasker.profile_details = [];
    }

    antsc.saveProf = function saveProf(valid, data, steps) {
        if (valid) {
            $scope.steps.step3 = true;
            var i = 0;
            for (var key in antsc.profileDetails) {

                if (antsc.profileDetails.filter(function (obj) { return obj.question === key; })[0]) {
                    antsc.tasker.profile_details[i].answer = antsc.profileDetails[key];
                } else {
                    antsc.tasker.profile_details.push({ 'question': key, 'answer': antsc.profileDetails[key] });
                }
                i++;
            }
            steps.step4 = true
        } else {
            toastr.error('form is invalid');
        }
    }
    antsc.emptyLatLng = function (temp_taskerareaaddress) {
        if (temp_taskerareaaddress != antsc.taskerareaaddress) {
            //  antsc.tasker.location = '';
        }
    }
    antsc.tasker1 = {};
    antsc.newsaveAvail = function () {
        if ((antsc.tasker.working_days[6].not_working == false || antsc.tasker.working_days[5].not_working == false ||
            antsc.tasker.working_days[4].not_working == false || antsc.tasker.working_days[3].not_working == false || antsc.tasker.working_days[2].not_working == false ||
            antsc.tasker.working_days[1].not_working == false || antsc.tasker.working_days[0].not_working == false)) {
            if (antsc.tasker.location == '' || antsc.tasker.location == 'undefined') {
                toastr.error("Invalid Availability Location");
                return;
            } else {
                if (antsc.tasker.working_days) {
                    antsc.tasker1 = angular.copy(antsc.tasker);
                    antsc.tasker.working_days = $filter('filter')(antsc.tasker.working_days, { "not_working": false });
                    TaskersService.addTasker(antsc.tasker, antsc.tasker1).then(function (response) {
                        var _id = "";
                        _id = response._id;
                        antsc.tasker._id = response._id;
                        toastr.success('Tasker Added Successfully');
                        $state.go('app.taskers.list');
                    }, function (err) {
                        toastr.error('Unable to process your request');
                    });
                } else {
                    toastr.error("Please Select The Working days");
                }
            }
        }
        else {
            toastr.error('Please select your working days');
            //$translate('PLEASE SELECT YOUR WORKING DAYS').then(function (headline) { toastr.error(headline); }, function (translationId) { toastr.error(headline); });
        }
    }
}// function addNewTaskerCtrl End


angular.module('handyforall.taskers').controller('AvailabilityModalInstanceCtrl', function ($scope, $modalInstance, workingDays, workingTimes, DaysData, selectedIndex) {
    /* var aam = this;
     aam.day = data.days[data.day];
     aam.index = data.day;
     aam.working_day = workingDays[data.day];*/
    $scope.WorkingDays = workingDays[selectedIndex];
    $scope.workingTimes = workingTimes;
    $scope.days = DaysData;

    $scope.ok = function () {
        if ($scope.WorkingDays.hour.morning == true || $scope.WorkingDays.hour.afternoon == true || $scope.WorkingDays.hour.evening == true) {
            $scope.WorkingDays.not_working = false;
        } else {
            $scope.WorkingDays.not_working = true;
        }
        $modalInstance.close($scope.WorkingDays, selectedIndex);
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});


/*angular.module('handyforall.taskers').controller('AvailabilityModalInstanceCtrl', function ($modalInstance, data, workingDays) {
    var aam = this;
    aam.day = data.days[data.day];
    aam.index = data.day;
    aam.working_day = workingDays[data.day];
    aam.ok = function (working_day, index) {
        if (aam.working_day.hour.morning == true || aam.working_day.hour.afternoon == true || aam.working_day.hour.evening == true) {
            aam.working_day.not_working = false;
        } else {
            aam.working_day.not_working = true;
        }
        var data = { 'working_day': working_day, 'index': index };
        $modalInstance.close(data);
    };

    aam.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});*/

angular.module('handyforall.taskers').controller('ModalInstanceWorkingDayCtrl', function ($scope, $modalInstance, WorkingDays, selectedIndex) {

    $scope.totalData = {
        WorkingDays: {},
        selectedIndex: 0
    };
    $scope.WorkingDays = WorkingDays[selectedIndex];
    $scope.ok = function () {
        if ($scope.WorkingDays.hour.morning == true || $scope.WorkingDays.hour.afternoon == true || $scope.WorkingDays.hour.evening == true) {
            $scope.WorkingDays.not_working = false;
        } else {
            $scope.WorkingDays.not_working = true;
        }
        $scope.totalData.WorkingDays = $scope.WorkingDays;
        $scope.totalData.selectedIndex = selectedIndex;
        $modalInstance.close($scope.totalData);
    };

    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});




angular.module('handyforall.taskers').controller('DeleteCategoriesModalInstanceCtrl', function ($modalInstance, user, category) {

    var dcmic = this;
    dcmic.category = category;
    dcmic.user = user;

    var categoryinfo = {};
    categoryinfo.userid = user._id;
    categoryinfo.categoryid = category;


    dcmic.ok = function () {
        $modalInstance.close(categoryinfo);
    };

    dcmic.cancel = function () {
        $modalInstance.dismiss('cancel');
    };

});


angular.module('handyforall.taskers').controller('NewCategoriesModalInstanceCtrl', function (TaskersService, experiences, user, categories, category, toastr, $modalInstance, $scope, defaultCurrency) {
    var nacm = this;
    nacm.user = user;
    nacm.categories = categories;
    nacm.defaultcurrency = defaultCurrency;
    nacm.experiences = experiences;
    nacm.category = nacm.categories.filter(function (obj) {
        return obj._id === category;
    })[0];
    nacm.selectedCategoryData = {};
    nacm.selectedCategoryData.skills = [];
    if (nacm.category) {
        nacm.mode = 'Edit';
    } else {
        nacm.mode = 'Add';
    }
    for (var i = 0; i < nacm.user.taskerskills; i++) {
        if (nacm.user.taskerskills[i].categoryid == category) {
            nacm.selectedCategoryData = nacm.user.taskerskills[i];
        }
    }

    nacm.selectedCategoryData.userid = nacm.user._id;
    nacm.selectedCategoryData.categoryid = nacm.user.categoryid;

    nacm.onChangeCategory = function (category) {
        nacm.category = nacm.categories.filter(function (obj) {
            return obj._id === category;
        })[0];
    };
    nacm.onChangeCategoryChild = function (category) {
        TaskersService.getChild(category).then(function (response) {
            nacm.MinimumAmount = response.commision;
        });
        nacm.category = nacm.user.taskerskills.filter(function (obj) {

            if (obj.childid === category) {
                toastr.error('Already the Category is Exists');
                nacm.selectedCategoryData = {};
            }
        })[0];
    };
    nacm.ok = function (valid, data) {
        if (valid) {
            //if(nacm.selectedCategoryData.hour_rate < )
            toastr.success("Category  Added To the list Successfully");
            $modalInstance.close(nacm.selectedCategoryData);
        }
        else {
            toastr.error('Please enter all values');
        }
    };
    nacm.cancel = function () {
        $modalInstance.dismiss('cancel');

    };

});
