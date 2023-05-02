({
    init: function(component, event, helper) {
        var action = component.get("c.getRecords");
        action.setParams({
            recordId : component.get("v.recordId")
        });  
        action.setCallback(this, function(response) {
            var object = {};
            object.count = 0;
            object.listMatriz = response.getReturnValue();
            object.siguienteDes = object.listMatriz.length < 3;
            object.anteriorDes = true;
            
            component.set("v.data", object);
            helper.asignarMatriz(component);
            helper.hCancelar(component);
            helper.getClone(component);
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    agregarMatriz1: function(component, event, helper) {
        var data = component.get("v.dataShow");
        let name = event.getSource().get("v.name");
        var object = {};
        object.rangoMenor = 0;
        object.rangoMayor = 0;
        object.precio = 0;
        object.anio = name;
        object.index = data.matriz1.length + 1;
        data.matriz1.listMatriz.push(object);
        component.set("v.dataShow", data);
    },
    agregarMatriz2: function(component, event, helper) {
        var data = component.get("v.dataShow");
        let name = event.getSource().get("v.name");
        var object = {};
        object.rangoMenor = 0;
        object.rangoMayor = 0;
        object.precio = 0;
        object.anio = name;
        object.index = data.matriz2.length + 1;
        data.matriz2.listMatriz.push(object);
        component.set("v.dataShow", data);
    },
    siguiente: function(component, event, helper) {
        var data = component.get("v.data");
        data.count += 2;
        data.siguienteDes = data.count + 2 >= data.listMatriz.length;
        data.anteriorDes = false;
        component.set("v.data", data);
        console.log(data.count);
        helper.asignarMatriz(component);
    },
    anterior: function(component, event, helper) {
        var data = component.get("v.data");
        data.count -= 2;
        data.siguienteDes = false;
        let num=0;
        data.anteriorDes = num;
        component.set("v.data", data);
        helper.asignarMatriz(component);
    },
    guardar: function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.data.popGuardar", false);
        helper.asignarMatriz(component);
        helper.actualizarRegistros(component);
    },
    seleccionPag1: function(component, event, helper) {
        var dataShow = component.get("v.dataShow");
        let selecionado = false;
        for(const element of dataShow.matriz1.listMatriz){
            if(element.seleccionado){
                selecionado = true;
            }
        }
        dataShow.seleccionadoPag1 = selecionado;
        component.set("v.dataShow", dataShow);
    },
    seleccionPag2: function(component, event, helper) {
        var dataShow = component.get("v.dataShow");
        let selecionado = false;
        for(const element of dataShow.matriz2.listMatriz){
            if(element.seleccionado){
                selecionado = true
            }
        }
        dataShow.seleccionadoPag2 = selecionado;
        component.set("v.dataShow", dataShow);
    },
    seleccionTodosPag1: function(component, event, helper) {
        var dataShow = component.get("v.dataShow");
        for(const element of dataShow.matriz1.listMatriz){
            element.seleccionado =  dataShow.seleccionadoPag1;
        }
        component.set("v.dataShow", dataShow);
    },
    seleccionTodosPag2: function(component, event, helper) {
        var dataShow = component.get("v.dataShow");
        for(const element of dataShow.matriz2.listMatriz){
            element.seleccionado =  dataShow.seleccionadoPag2;
        }
        component.set("v.dataShow", dataShow);
    },
    popPag1: function(component, event, helper) {
        var object = component.get("v.data");
        object.popEliminarPag1 = true;
        object.popEliminarPag2 = false;
        component.set("v.data", object);
    },
    popPag2: function(component, event, helper) {
        var object = component.get("v.data");
        object.popEliminarPag1 = false;
        object.popEliminarPag2 = true;
        component.set("v.data", object);
    },
    popGuardar: function(component, event, helper) {
        var data = component.get("v.data");
        for(const element of data.listMatriz){
            for(let j=0; j<element.listMatriz.length; j++){
                if(element.listMatriz[j].rangoMenor == 0 || element.listMatriz[j].rangoMenor == null ||
                   element.listMatriz[j].rangoMayor == 0 || element.listMatriz[j].rangoMayor == null ||
                   element.listMatriz[j].precio == 0 || element.listMatriz[j].precio == null ||
                   element.listMatriz[j].codigo == null || element.listMatriz[j].codigo == ''){
                    helper.showMessage('error', "Por favor complete todos los campos.");
                    return;
                }
            }
        }
        component.set("v.data.popGuardar", true);
    },
    cancelar: function(component, event, helper) {
        helper.hCancelar(component);
    },
    eliminar: function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.eliminarData(component);
    }
})