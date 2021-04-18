angular.module('handyforall.taskers').controller('addTaskerCtrl', addTaskerCtrl);

addTaskerCtrl.$inject = ['taskerAddServiceResolve', '$filter', '$state', 'TaskersService', '$scope', '$modal', 'toastr', 'CategoryServiceResolve', '$timeout', '$http', '$stateParams', 'NgMap'];

function addTaskerCtrl(taskerAddServiceResolve, $filter, $state, TaskersService, $scope, $modal, toastr, CategoryServiceResolve, $timeout, $http, $stateParams, NgMap) {

    $scope.render = false;
    var atsc = this;
    if ($stateParams.id) {
        atsc.stateDummyVariable = "Updated";
    } else {
        atsc.stateDummyVariable = "Added";
    }
	
	    var atsc = this;
    if (atsc.tasker === 'undefined') {
        atsc.tasker = taskerAddServiceResolve[0];
    }
	
	atsc.radiusby = $scope.gensettings.distanceby
	if(atsc.radiusby == 'km'){
		atsc.radiusval = 1000;
	}
	else{
		atsc.radiusval = 1609.34;
	}

    var workingDays = [{ day: "Sunday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Monday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Tuesday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Wednesday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Thursday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Friday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true },
    { day: "Saturday", hour: { "morning": false, "afternoon": false, "evening": false }, not_working: true }];

    $scope.visibleValue = false;
    // Croping
    $scope.myImage = '';
    atsc.myCroppedImage = '';
    //$scope.cropType = 'circle'; // circle & square
    $scope.handleFileSelect = function (evt) {
        //console.log("indisede");
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


    if (taskerAddServiceResolve) {
        atsc.tasker = taskerAddServiceResolve || {};
        if (atsc.tasker.availability == 1) {
            atsc.availabilityvalue = true;
        }
        else {
            atsc.availabilityvalue = false;
        }

        $scope.maps = [];
        $scope.$on('mapInitialized', function (evt, evtMap) {
            $scope.maps.push(evtMap);
        });

        atsc.AvailabilityMap = function () {
            $timeout(function () {
                google.maps.event.trigger($scope.maps[0], 'resize');
                $scope.maps[0].setCenter(new google.maps.LatLng(atsc.tasker.location.lat, atsc.tasker.location.lng));
            }, 100);
        }

        atsc.mapToInput = function (event) {

            if ($scope.maps[0]) {
                atsc.tasker.radius = parseInt($scope.maps[0].shapes.circle.radius / atsc.radiusval);
                var lat = $scope.maps[0].shapes.circle.center.lat();
                var lng = $scope.maps[0].shapes.circle.center.lng();
                var latlng = new google.maps.LatLng(lat, lng);
                var geocoder = geocoder = new google.maps.Geocoder();
                geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                    if (status == 'OK') {
                        $scope.$apply(function () {
                            atsc.tasker.availability_address = results[0].formatted_address;
                            atsc.place = {};
                            atsc.tasker.location.lng = lng;
                            atsc.tasker.location.lat = lat;
                        });
                    }

                });
            }
        }

        if (atsc.tasker.location) {
            var latlng = new google.maps.LatLng(atsc.tasker.location.lat, atsc.tasker.location.lng);
            var geocoder = geocoder = new google.maps.Geocoder();
            geocoder.geocode({ 'latLng': latlng }, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                    if (results[1]) {
                        if (atsc.tasker.availability_address) {
                            atsc.tasker.availability_address = atsc.tasker.availability_address;
                            atsc.tasker.temp_availability_address = atsc.tasker.availability_address;
                        } else {
                            atsc.tasker.availability_address = results[1].formatted_address;
                            atsc.tasker.temp_availability_address = results[1].formatted_address;
                        }
                        atsc.dummyAddress = 1;
                    }
                }
            });
        }

        if (taskerAddServiceResolve.birthdate) {
            atsc.dob = new Date(taskerAddServiceResolve.birthdate.year, taskerAddServiceResolve.birthdate.month - 1, taskerAddServiceResolve.birthdate.date)
        }
    } else {
        atsc.tasker = {
            name: {},
            phone: {},
            gender: '',
            userName: '',
            password: '',
            newpassword: '',
            new_confirmed: '',
            birthdate: { year: '', month: '', date: '' },
            address: {
                line1: '',
                line2: '',
                city: '',
                country: ''
            },
            working_days: workingDays,
            location: '',
            working_area: [],
            profile_details: { about: '', experience: '', job: '' },
            vechile_access: '',
            vechile_type: { v_bike: false, v_car: false, v_van: false, v_truck: false },
            avatar: '',
            next: 'step2',
            taskerskills: []
        };
        $scope.today = function () {
            atsc.dob = new Date();
            atsc.tasker.birthdate.year = atsc.dob.getFullYear();
            atsc.tasker.birthdate.month = atsc.dob.getMonth() + 1;
            atsc.tasker.birthdate.date = atsc.dob.getDate();
        };
        $scope.today();
    }
    atsc.dateChange = function () {
        atsc.tasker.birthdate.year = atsc.dob.getFullYear();
        atsc.tasker.birthdate.month = atsc.dob.getMonth() + 1;
        atsc.tasker.birthdate.date = atsc.dob.getDate();
        if (calculate_age(atsc.tasker.birthdate.month, atsc.tasker.birthdate.date, atsc.tasker.birthdate.year, atsc.dob)) {
            atsc.tasker.birthdate.year = atsc.dob.getFullYear();
            atsc.tasker.birthdate.month = atsc.dob.getMonth() + 1;
            atsc.tasker.birthdate.date = atsc.dob.getDate();
            atsc.tasker.dob = antsc.dob;

        }
        else {
            toastr.error('Yours age should be 18+');
        }

    };
    function calculate_age(birth_month, birth_day, birth_year, dobdate) {
        // var today_date = new Date();
        // var today_year = today_date.getFullYear();
        // var today_month = today_date.getMonth();
        // var today_day = today_date.getDate();
        // var age = today_year - birth_year;

        // if (today_month < (birth_month - 1)) {
        //     age--;
        // }
        // if (((birth_month - 1) == today_month) && (today_day < birth_day)) {
        //     age--;
        // }
        // return age;
        var names = dobdate.getDate();
        var month = dobdate.getMonth() + 1;
        var year = dobdate.getFullYear();
        console.log("names,month,year", names, month, year);
        var date = new Date();
        var currentDate = date.getDate();
        var currentMonth = date.getMonth() + 1;
        var conditionyear = date.getFullYear() - 18;
        console.log("names,month,year", conditionyear, currentMonth, currentDate);
        if (conditionyear == year) {
            if (month <= currentMonth) {
                if (names <= currentDate) {
                    return true;
                } else {
                    //toastr.error("Tasker Age must be above 18!");
                    return false;

                }
            } else {
                //toastr.error("Tasker Age must be above 18!");
                return false;


            }

        } else if (conditionyear < year) {
            //toastr.error("Tasker Age must be above 18!");
            return false;
        } else if (conditionyear > year) {
            return true;
        }

    }
    atsc.placeChanged = function () {
        atsc.tasker.address.line2 = '';
        atsc.tasker.address.country = '';
        atsc.tasker.address.zipcode = '';
        atsc.tasker.address.state = '';
        atsc.place = this.getPlace();
        // .log("atsc.place",atsc.place);

        //atsc.tasker.location.lng = atsc.place.geometry.location.lng();
        //atsc.tasker.location.lat = atsc.place.geometry.location.lat();
        var locationa = atsc.place;
        atsc.tasker.address.line1 = atsc.place.formatted_address;
        atsc.tasker.address.line2 = '';

        if (locationa.name) {
            atsc.tasker.address.line1 = locationa.name;
        }

        for (var i = 0; i < locationa.address_components.length; i++) {
            for (var j = 0; j < locationa.address_components[i].types.length; j++) {
                if (locationa.address_components[i].types[j] == 'neighborhood') {
                    if (atsc.tasker.address.line1 != locationa.address_components[i].long_name) {
                        if (atsc.tasker.address.line1 != '') {
                            atsc.tasker.address.line1 = atsc.tasker.address.line1 + ',' + locationa.address_components[i].long_name;
                        } else {
                            atsc.tasker.address.line1 = locationa.address_components[i].long_name;
                        }
                    }
                }
                if (locationa.address_components[i].types[j] == 'route') {
                    if (atsc.tasker.address.line1 != locationa.address_components[i].long_name) {
                        if (atsc.tasker.address.line2 != '') {
                            atsc.tasker.address.line2 = atsc.tasker.address.line2 + ',' + locationa.address_components[i].long_name;
                        } else {
                            atsc.tasker.address.line2 = locationa.address_components[i].long_name;
                        }
                    }

                }
                if (locationa.address_components[i].types[j] == 'street_number') {
                    if (atsc.tasker.address.line2 != '') {
                        atsc.tasker.address.line2 = atsc.tasker.address.line2 + ',' + locationa.address_components[i].long_name;
                    } else {
                        atsc.tasker.address.line2 = locationa.address_components[i].long_name;
                    }

                }
                if (locationa.address_components[i].types[j] == 'sublocality_level_1') {
                    if (atsc.tasker.address.line2 != '') {
                        atsc.tasker.address.line2 = atsc.tasker.address.line2 + ',' + locationa.address_components[i].long_name;
                    } else {
                        atsc.tasker.address.line2 = locationa.address_components[i].long_name;
                    }

                }
                if (locationa.address_components[i].types[j] == 'locality') {

                    atsc.tasker.address.city = locationa.address_components[i].long_name;
                }
                if (locationa.address_components[i].types[j] == 'country') {

                    atsc.tasker.address.country = locationa.address_components[i].long_name;
                }
                if (locationa.address_components[i].types[j] == 'postal_code') {

                    atsc.tasker.address.zipcode = locationa.address_components[i].long_name;
                }
                if (locationa.address_components[i].types[j] == 'administrative_area_level_1' || locationa.address_components[i].types[j] == 'administrative_area_level_2') {
                    atsc.tasker.address.state = locationa.address_components[i].long_name;
                }
            }
        }
    };

    atsc.submitTaskerEditData = function submitTaskerEditData(isValid) {
        atsc.tasker.role = "tasker";
        if (calculate_age(atsc.tasker.birthdate.month, atsc.tasker.birthdate.date, atsc.tasker.birthdate.year, atsc.dob)) {

            if (!atsc.tasker.avatar) {
                toastr.error('Form is Invalid');
            } else {
                if (isValid) {
                    atsc.tasker.avatarBase64 = atsc.myCroppedImage;
                    TaskersService.addTaskergeneral(atsc.tasker).then(function (response) {
                        console.log("response///////////////", response);
                        if (response == "" || response.msg == "Phone Number Already Exists") {
                            toastr.error(response.msg);
                        } else if (response.msg == "Username Already Exists") {
                            toastr.error(response.msg);
                        } else if (response.msg == "Email Already Exists") {
                            toastr.error(response.msg);
                        } else if (response.msg == "success") {
                            toastr.success("Tasker " + atsc.stateDummyVariable + " Successfully");
                            $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
                        }
                    }, function (err) {
                        toastr.error('Unable to process your request');
                    });
                } else {
                    toastr.error('form is invalid');
                }
            }
        } else {
            toastr.error('Yours age should be 18+');
        }

    };


    atsc.savepassword = function savepassword(valid) {
        atsc.tasker.role = "tasker";
        if (valid) {
            TaskersService.savetaskerpassword(atsc.tasker).then(function (response) {
                toastr.success('Password Saved Successfully');
                $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
            }, function (err) {
                toastr.error('Unable to process your request');
            });
        } else {
            toastr.error('form is invalid');
        }

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

    atsc.selectedCategory = function (index) {
        atsc.selectedcategory = $filter('filter')(atsc.categoryList, { "active": true });
        atsc.selectedcategory[0].active = false;
        atsc.categoryList[index].active = true;
        atsc.selectedcategory = atsc.categoryList[index];
        atsc.flag = false;
    };

    atsc.categoryList = CategoryServiceResolve[0];
    angular.forEach(atsc.categoryList, function (value) {
        value.active = false;
        value.terms = false;
        value.quick_pitch = '';
        value.hour_rate = '';
        value.experience = '';
        value.file = '';
        angular.forEach(value.skills, function (skills) {
            skills.selected = false;
        })
    });
    atsc.categoryList[0].active = true;
    atsc.selectedcategory = [];
    atsc.selectedcategory = atsc.categoryList[0];

    angular.forEach(atsc.tasker.taskerskills, function (taskerskills) {
        angular.forEach(atsc.categoryList, function (categoryList) {
            if (taskerskills.categoryid == categoryList._id) {
                categoryList.terms = taskerskills.terms;
                categoryList.quick_pitch = taskerskills.quick_pitch;
                categoryList.hour_rate = taskerskills.hour_rate;
                categoryList.experience = taskerskills.experience;
                //categoryList.file=taskerskills.file;
                angular.forEach(taskerskills.skills, function (taskerskillArr) {
                    angular.forEach(categoryList.skills, function (categoryskillArr) {
                        if (categoryskillArr.tags == taskerskillArr.tags) {
                            categoryskillArr.selected = true;
                        }
                    });
                });
            }
        })
    });
    //mark
    atsc.selectedCategory = function (index) {
        atsc.selectedcategory = $filter('filter')(atsc.categoryList, { "active": true });
        atsc.selectedcategory[0].active = false;
        atsc.categoryList[index].active = true;
        atsc.selectedcategory = atsc.categoryList[index];
        atsc.flag = false;
    };

    atsc.availabilitiesModelOpen = function (size, index) {
        var modalInstance = $modal.open({
            animation: true,
            template: '<div class="availabilities-day-form adminweekmodal" ><div class=""><div class=""><div class="modal-header modal-header-success"><button class="close" type="button" ng-click="cancel()">×</button><h1 class="day-text">{{WorkingDays.day}}</h1></div><div class="modal-body"><ul class="radio-contr"><li><input ng-model ="WorkingDays.hour.morning" id="morning" class="u-hidden" type="checkbox" value="morning" name="windowFields"><label class="switch" for="morning"></label><label for="morning">Morning (8am - 12pm)</label></li><li><input ng-model ="WorkingDays.hour.afternoon" id="evenig" class="u-hidden" type="checkbox" value="morning" name="windowFields"><label class="switch" for="evenig"></label><label for="evenig">Afternoon (12pm - 4pm)</label></li><li><input id="afternoon" ng-model ="WorkingDays.hour.evening" class="u-hidden" type="checkbox" value="morning" name="windowFields"><label class="switch" for="afternoon"></label><label for="afternoon">Evening (4pm - 8pm)</label></li></ul></div><div class="modal-footer"><button type="button" class="btn btn-default pull-left" ng-click="ok()" >Save</button></div></div></div></div>',
            controller: 'ModalInstanceWorkingDayCtrl',
            size: size,
            resolve: {
                WorkingDays: function () {
                    return atsc.tasker.working_days;
                },
                selectedIndex: function () {
                    return index;
                }
            }
        });

        modalInstance.result.then(function (WorkingDays) {
            atsc.tasker.working_days[WorkingDays.selectedIndex] = WorkingDays.WorkingDays;
        }, function (dasd) {
        });
    };


    atsc.taskerareaChanged = function () {
        atsc.place = this.getPlace();
        atsc.tasker.location = {};
        atsc.tasker.location.lng = atsc.place.geometry.location.lng();
        atsc.tasker.location.lat = atsc.place.geometry.location.lat();
        if (typeof atsc.place.geometry.location.lng() != 'undefined' && typeof atsc.place.geometry.location.lat() != 'undefined') {
            //btc.data.centerMap = btc.data.location;
            var locationa = atsc.place;
            atsc.tasker.availability_address = atsc.place.formatted_address;
            var dummy = locationa.address_components.filter(function (value) {
                return value.types[0] == "sublocality_level_1";
            }).map(function (data) {
                return data;
            });
            atsc.dummyAddress = dummy.length;
            atsc.tasker.availability_address = atsc.tasker.temp_availability_address;
        } else {
            toastr.error('Invalid Location')
        }
    };
    $scope.maps = [];
    $scope.$on('mapInitialized', function (evt, evtMap) {
        $scope.maps.push(evtMap);
    });
    atsc.emptyLatLng = function (temp_address) {
        if (typeof temp_address != 'undefined' && temp_address != atsc.tasker.availability_address) {
            atsc.tasker.location = '';
        }
    }
    atsc.saveAvailability = function () {
        if (atsc.tasker.location == '') {
            toastr.error('Invalid Location');
            return;
        } else {
            if (atsc.tasker.location != '') {
                TaskersService.saveAvailability(atsc.tasker).then(function (response) {
                    toastr.success('Updated Successfully');
                    $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
                }, function (err) {
                    if (err.msg) {
                        toastr.error('danger', err.msg);
                    } else {
                        toastr.error('Unable to save your data');
                    }
                });
            } else {
                toastr.error('Invalid Location');
            }
        }

    }
    // About Tab
    TaskersService.getQuestion().then(function (respo) {
        atsc.getQuestion = respo;
    });
    if (atsc.tasker.profile_details[0]) {
        atsc.profileDetails = atsc.tasker.profile_details.reduce(function (total, current) {
            total[current.question] = current.answer;
            return total;
        }, {});
    } else {
        atsc.profileDetails = [];
    }
    atsc.saveProfile = function saveProfile() {
        var i = 0;
        for (var key in atsc.profileDetails) {
            if (atsc.tasker.profile_details.filter(function (obj) { return obj.question === key; })[0]) {
                atsc.tasker.profile_details[i].answer = atsc.profileDetails[key];
            } else {
                atsc.tasker.profile_details.push({ 'question': key, 'answer': atsc.profileDetails[key] });
            }
            i++;
        }

        TaskersService.saveProfile(atsc.tasker).then(function (response) {
            toastr.success('Updated Successfully');
            $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
        }, function (err) {
            if (err.msg) {
                toastr.error('danger', err.msg);
            } else {
                toastr.error('Unable to save your data');
            }
        });
    }

    TaskersService.gettaskercategory(atsc.tasker._id).then(function (respo) {
        atsc.taskercategory = respo;
    });
    TaskersService.getCategories().then(function (respo) {
        atsc.categories = respo;
    });
    TaskersService.defaultCurrency().then(function (respo) {
        atsc.defaultCurrency = respo;
    });
    TaskersService.getExperience().then(function (respo) {
        atsc.experiences = respo;
    });
    atsc.addcat = function () {
        TaskersService.gettaskercategory(atsc.tasker._id).then(function (respo) {
            atsc.taskercategory = respo;
        });
    }
    atsc.approvtaskercat = function () {
        TaskersService.gettaskercategory(atsc.tasker._id).then(function (respo) {
            atsc.taskercategory = respo;
        });
    }
    atsc.categoryModal = function (category) {
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: 'app/admin/modules/taskers/views/editcategory.modal.tab.html',
            controller: 'CategoriesModalInstanceCtrl',
            controllerAs: 'ACM',
            resolve: {
                experiences: function () {
                    return atsc.experiences;
                },
                user: function (TaskersService, $stateParams) {//console.log(atsc.tasker._id);
                    if (category) {
                        return TaskersService.edit(atsc.tasker._id); console.log(atsc.tasker._id, "fffffff");
                    } else {
                        return atsc.tasker; console.log(atsc.tasker);
                    }
                },
                categories: function () {
                    return atsc.categories;
                },
                category: function () {
                    return category;
                },
                defaultCurrency: function () {
                    return atsc.defaultCurrency;
                }
            }
        });
        modalInstance.result.then(function (selectedCategoryData) {
            TaskersService.addCategory(selectedCategoryData).then(function (response) {
                toastr.success('Updated Successfully');
                $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
                atsc.addcat();
            }, function () {
                if (err.msg) {
                    $scope.addAlert('danger', err.msg);
                } else {
                    $scope.addAlert('Unable to save your data');
                }
            });
        }, function () {
            /*	if (err.msg) {
                    toastr.success('danger', err.msg);
                } else {
                    $scope.addAlert('danger', 'Unable to save your data');
                }*/
        });

    };

    atsc.deletecategory = function (category) {
        var modalInstance = $modal.open({
            animation: true,
            templateUrl: 'app/admin/modules/taskers/views/deletecategory.modal.tab.html',
            controller: 'DeleteCategoriesModalInstanceCtrl',
            controllerAs: 'DCMIC',
            resolve: {
                user: function () {
                    return atsc.tasker;
                },
                category: function () {
                    return category;
                }
            }

        });
        modalInstance.result.then(function (deletecategorydata) {

            TaskersService.deleteCategory(deletecategorydata).then(function (response) {
                TaskersService.gettaskercategory(atsc.tasker._id).then(function (respo) {
                    atsc.taskercategory = respo;

                });
            }, function () {

            });
        });
    }

    atsc.approvtaskercategory = function (category, status) {

        var data = {};
        data.tasker = atsc.tasker._id;
        data.category = category;

        TaskersService.approvtaskercategory(data, status).then(function (response) {
            if (response.code == 11000) {
                toastr.error('Error');
            }
            else {
                if (response.data.status == 1) {
                    atsc.approvtaskercat();
                    toastr.success('Category Verified Successfully');
                }
                else if (response.data.status == 2) {
                    atsc.approvtaskercat();
                    toastr.success('Category UnVerified Successfully');
                }
            }
        });
    }
    //Availability Tab
    atsc.availability = {};

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
    atsc.workingDays = workingDays;

    var DaysData = [{ Morning: "MORNING", afternoon: "AFTERNOON", evening: "EVENING", Save: "SAVE" }];
    console.log("atsc.tasker.working_days", atsc.tasker.working_days);
    angular.forEach(atsc.workingDays, function (workingDays, key) {
        angular.forEach(atsc.tasker.working_days, function (UserWorkingdays) {
            if (UserWorkingdays.day == workingDays.day) {
                console.log("wwww", UserWorkingdays.hour.morning);
                console.log("wwww", UserWorkingdays.day);
                if (UserWorkingdays.hour.morning == true || UserWorkingdays.hour.afternoon == true || UserWorkingdays.hour.evening == true) {
                    UserWorkingdays.not_working = false;
                    atsc.workingDays[key] = UserWorkingdays;
                    console.log("atsc.workingDays", atsc.workingDays);
                }
            }
        })
    });

    atsc.availabilityChange = function (value) {
        atsc.data = {};
        if (value == false) {
            atsc.data.availability = 0;
        } else {
            atsc.data.availability = 1;
        }
        atsc.data._id = atsc.tasker._id;

        TaskersService.updateAvailability(atsc.data).then(function (response) {

            toastr.success('Tasker Availability Updated Successfully');
            $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
        }, function (err) {
            if (err.msg) {
                $scope.addAlert('danger', err.msg);
            } else {
                toastr.error('Unable to save your Availability');
            }
        });
    };

    atsc.banking = taskerAddServiceResolve.banking;
    atsc.saveaccountinfo = function saveaccountinfo(isvalid, data) {
        atsc.banking.userId = $stateParams.id;

        if (isvalid) {
            TaskersService.saveaccountinfo(data).then(function (response) {
                toastr.success('Tasker Account Info Updated Successfully');
                $state.go('app.taskers.list', { page: $stateParams.page, items: $stateParams.items });
            }, function (err) {
                if (err.message) {
                    toastr.error(err.message);
                } else {
                    toastr.error('Unable to save your Account Info');
                }
            });
        } else {
            $translate('please fill all mandatory fileds').then(function (headline) {
                toastr.error(headline);
            }, function (translationId) {
                toastr.error(headline);
            });
        }
    };



    atsc.availabilityModal = function (size, index) {

        var modalInstance = $modal.open({
            animation: true,
            keyboard: false,
            templateUrl: 'app/admin/modules/taskers/views/availability.modal.tab.html',
            controller: 'AvailabilityModalCtrl',
            windowClass: 'avail-window',
            //controllerAs: 'AAM',
            resolve: {
                /*  data: function () {
                      return { 'day': day, 'days': atsc.availability.days };
                  },
                  workingDays: function () {
                      return atsc.workingDays;
                  }*/
                workingDays: function () {
                    return atsc.workingDays;
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
            //atsc.workingDays[data.index] = data.working_day;
            //atsc.workingVariable = $filter('filter')(atsc.workingDays, { "not_working": false });
            atsc.tasker.working_days[index] = WorkingDays;
        }, function () {
        });
    }
}

angular.module('handyforall.taskers').controller('AvailabilityModalCtrl', function ($scope, $modalInstance, workingDays, workingTimes, DaysData, selectedIndex) {

    /*var aam = this;
    aam.day = data.days[data.day];
    aam.index = data.day;
    aam.working_day = workingDays[data.day];*/
    $scope.WorkingDays = workingDays[selectedIndex];
    console.log("$scope.WorkingDays", $scope.WorkingDays);
    $scope.workingTimes = workingTimes;
    $scope.days = DaysData;

    $scope.ok = function () {
        if ($scope.WorkingDays.hour.morning == true || $scope.WorkingDays.hour.afternoon == true || $scope.WorkingDays.hour.evening == true) {
            $scope.WorkingDays.not_working = false;
        } else {
            $scope.WorkingDays.not_working = true;
        }
        console.log($scope.WorkingDays, selectedIndex)
        $modalInstance.close($scope.WorkingDays, selectedIndex);
    };

    $scope.cancel = function (WorkingDays) {
        $modalInstance.dismiss('cancel');
        console.log(WorkingDays);
        // $scope.WorkingDays.hour.morning= false
        // $scope.WorkingDays.hour.afternoon= false
        // $scope.WorkingDays.hour.evening= false
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

angular.module('handyforall.taskers').controller('CategoriesModalInstanceCtrl', function (TaskersService, experiences, user, categories, category, toastr, $modalInstance, defaultCurrency) {
    var acm = this;
    if (category) {
        acm.role = 'edit';
    }
    else {
        acm.role = 'new';
    }

    acm.user = user;
    acm.categories = categories;
    acm.experiences = experiences;

    acm.defaultcurrency = defaultCurrency;
    acm.category = acm.categories.filter(function (obj) {
        return obj._id === category;
    })[0];


    acm.selectedCategoryData = {};
    acm.selectedCategoryData.skills = [];

    if (acm.category) {
        acm.mode = 'Edit';
    } else {
        acm.mode = 'Add';
    }

    for (var i = 0; i < acm.user.taskerskills.length; i++) {
        if (acm.user.taskerskills[i].childid == category) {
            acm.selectedCategoryData = acm.user.taskerskills[i];
        }
    }
    // console.log((acm.selectedCategoryData.hour_rate *acm.defaultcurrency.value).toFixed(2));
    // acm.selectedCategoryData.hour_rate  = parseFloat(acm.selectedCategoryData.hour_rate * acm.defaultcurrency.value).toFixed(2);
    // acm.selectedCategoryData.hour_rate = parseFloat((acm.selectedCategoryData.hour_rate * acm.defaultcurrency.value).toFixed(2));

    acm.selectedCategoryData.userid = acm.user._id;
    acm.onChangeCategory = function (category) {
        acm.category = acm.categories.filter(function (obj) {
            return obj._id === category;
        })[0];
    };
    acm.onChangeCategoryChild = function (category) {
        TaskersService.getChild(category).then(function (response) {
            acm.MinimumAmount = response.commision;
        });
        acm.category = acm.user.taskerskills.filter(function (obj) {
            if (obj.childid === category) {
                toastr.error('Already the Category is Exists');
                //  $modalInstance.dismiss('cancel');
                acm.selectedCategoryData = {};
            }
        })[0];
    };
    if (acm.selectedCategoryData.childid) {
        TaskersService.getChild(acm.selectedCategoryData.childid).then(function (response) {
            acm.MinimumAmount = response.commision;
        });
    }

    acm.ok = function (valid) {
        if (valid) {
            $modalInstance.close(acm.selectedCategoryData);
        } else {
            toastr.error('Please enter all values');
        }
    };
    acm.cancel = function () {
        $modalInstance.dismiss('cancel');
    };
});
