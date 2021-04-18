angular.module('handyforall.categories').controller('editCategoryCtrl', editCategoryCtrl);

editCategoryCtrl.$inject = ['categoryEditReslove', 'CategoryService', 'toastr', '$state', '$stateParams', 'Slug'];

function editCategoryCtrl(categoryEditReslove, CategoryService, toastr, $state, $stateParams, Slug) {
    var ecatc = this;

    ecatc.mainPagesList = categoryEditReslove[0];
    ecatc.editCategoryData = {};
    ecatc.editCategoryData = categoryEditReslove[1];

    if ($stateParams.id) {
        ecatc.action = 'edit';
        ecatc.breadcrumb = 'SubMenu.EDIT_CATEGORY';
    } else {
        ecatc.action = 'add';
        ecatc.breadcrumb = 'SubMenu.ADD_CATEGORY';
    }

    CategoryService.getSetting().then(function (response) {
        ecatc.editsettingData = response[0].settings.site_url;
    })
    ecatc.disbledValue = false;
    ecatc.submit = function submit(isValid, data) {
        if (isValid) {
            ecatc.disbledValue = true;
            data.slug = Slug.slugify(data.slug);
            CategoryService.savecategory(data).then(function (response) {
                toastr.success('Category Added Successfully');
                $state.go('app.categories.list', { page: $stateParams.page, items: $stateParams.items });
            }, function (err) {
                toastr.error('Unable to process your request');
            });
        } else {
            toastr.error('form is invalid');
        }

    };

}
