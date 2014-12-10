#import <Foundation/Foundation.h>

@import ObjectiveC.runtime;

void classDump(Class cls) {
    unsigned methodCount;
    Method *methodList = class_copyMethodList(cls, &methodCount);
    
    puts("-------------");
    printf("%s\n", class_getName(cls));
    
    for (unsigned methodIndex = 0; methodIndex < methodCount; methodIndex++) {
        Method method = methodList[methodIndex];
        
        printf("\t-%s\n", sel_getName(method_getName(method)));
    }
    
    free(methodList);
    puts("-------------");
}