//
//  SVIgnore.h
//  Singer Song Reader
//
//  Created by Developer on 4/6/14.
//
//

#define IGNORE_IMPLEMENTATION \
- (BOOL)accessibilityIsIgnored {\
    return YES;\
}\
\
- (id)accessibilityAttributeValue:(NSString *)attribute\
{\
    if ( [attribute isEqualToString:NSAccessibilityChildrenAttribute] )\
        return NSAccessibilityUnignoredChildren(self.subviews);\
        \
        else if ( [attribute isEqualToString:NSAccessibilityParentAttribute] )\
            return NSAccessibilityUnignoredAncestor(self.superview);\
            \
            else\
                return [super accessibilityAttributeValue:attribute];\
}\

