angular.module('handyforall.postheader').controller('editPostheaderCtrl', editPostheaderCtrl);

editPostheaderCtrl.$inject = ['toastr', '$state', 'PostheaderService', 'postheaderServiceResolve', '$stateParams'];

function editPostheaderCtrl(toastr, $state, PostheaderService, postheaderServiceResolve, $stateParams) {
    var ephc = this;
    ephc.editpostheaderData = postheaderServiceResolve;
    if ($stateParams.id) {
        ephc.action = 'edit';
        ephc.breadcrumb = 'SubMenu.EDIT_POSTHEADER';
    } else {
        ephc.action = 'add';
        ephc.breadcrumb = 'SubMenu.ADD_POSTHEADER';
    }

    PostheaderService.getPostHeaderList().then(function (respo) {

        ephc.postHeaderListCount = respo[1];


        if ($stateParams.id) {

            ephc.submit = function submit(isValid) {
                if (isValid) {
                    PostheaderService.save(ephc.editpostheaderData).then(function (response) {
                        toastr.success('Postheader Updated Successfully');
                        $state.go('app.postheader.viewpostheader');
                    }, function (err) {
                        toastr.error('Unable to process your request');
                    });
                }
                else {
                    toastr.error('form is invalid');
                }
            };

        } else {
            if (ephc.postHeaderListCount >= 3) {
                toastr.error('Maximum Count for Postheader is 3, More Postheader Cannot be Added');
                $state.go('app.postheader.viewpostheader');
            } else {
                ephc.submit = function submit(isValid) {
                    if (isValid) {
                        PostheaderService.save(ephc.editpostheaderData).then(function (response) {
                            toastr.success('Postheader Added Successfully');
                            $state.go('app.postheader.viewpostheader');
                        }, function (err) {
                            toastr.error('Unable to process your request');
                        });
                    } else {
                        toastr.error('form is invalid');
                    }

                };
            }
        }
    });


}
