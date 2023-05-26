const newLocal = {
    handleClick: function (cmp, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var refreshAction = $A.get("e.force:refreshView");
        refreshAction.fire();
    }
};