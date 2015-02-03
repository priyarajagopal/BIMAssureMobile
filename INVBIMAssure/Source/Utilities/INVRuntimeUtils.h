//
//  INVRuntimeUtils.h
//  INVBIMAssure
//
//  Created by Richard Ross on 2/3/15.
//  Copyright (c) 2015 Invicara Inc. All rights reserved.
//
@import ObjectiveC.runtime;

static inline IMP safeSwapMethods(restrict Class kls, restrict SEL oldName, restrict SEL newName) {
    Class superKls = class_getSuperclass(kls);
    
    Method oldMethod = class_getInstanceMethod(kls, oldName);
    Method superclassMethod = class_getInstanceMethod(superKls, oldName);
    
    Method newMethod = class_getInstanceMethod(kls, newName);
    
    IMP oldImp = method_getImplementation(oldMethod);
    IMP newImp = method_getImplementation(newMethod);
    
    if (oldMethod == superclassMethod) {
        class_addMethod(kls, oldName, newImp, method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
    
    return oldImp;
}