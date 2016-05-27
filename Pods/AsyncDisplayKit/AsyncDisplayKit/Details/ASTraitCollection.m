//
//  ASDisplayTraits.m
//  AsyncDisplayKit
//
//  Created by Ricky Cancro on 5/4/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "ASTraitCollection.h"
#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASAvailability.h>

@implementation ASTraitCollection

- (instancetype)initWithDisplayScale:(CGFloat)displayScale
                  userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
                 horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass
                   verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
                forceTouchCapability:(UIForceTouchCapability)forceTouchCapability
              traitCollectionContext:(id)traitCollectionContext
{
    self = [super init];
    if (self) {
      _displayScale = displayScale;
      _userInterfaceIdiom = userInterfaceIdiom;
      _horizontalSizeClass = horizontalSizeClass;
      _verticalSizeClass = verticalSizeClass;
      _forceTouchCapability = forceTouchCapability;
      _traitCollectionContext = traitCollectionContext;
    }
    return self;
}

+ (ASTraitCollection *)traitCollectionWithDisplayScale:(CGFloat)displayScale
                                    userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
                                   horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass
                                     verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
                                  forceTouchCapability:(UIForceTouchCapability)forceTouchCapability
                                traitCollectionContext:(id)traitCollectionContext
{
  return [[[self class] alloc] initWithDisplayScale:displayScale
                                 userInterfaceIdiom:userInterfaceIdiom
                                horizontalSizeClass:horizontalSizeClass
                                  verticalSizeClass:verticalSizeClass
                               forceTouchCapability:forceTouchCapability
                             traitCollectionContext:traitCollectionContext];
}

+ (ASTraitCollection *)traitCollectionWithASEnvironmentTraitCollection:(ASEnvironmentTraitCollection)traits
{
  return [[[self class] alloc] initWithDisplayScale:traits.displayScale
                                 userInterfaceIdiom:traits.userInterfaceIdiom
                                horizontalSizeClass:traits.horizontalSizeClass
                                  verticalSizeClass:traits.verticalSizeClass
                               forceTouchCapability:traits.forceTouchCapability
                             traitCollectionContext:traits.displayContext];

}

+ (ASTraitCollection *)traitCollectionWithUITraitCollection:(UITraitCollection *)traitCollection
                                     traitCollectionContext:(id)traitCollectionContext
{
  ASTraitCollection *asyncTraitCollection = nil;
  if (AS_AT_LEAST_IOS9) {
    asyncTraitCollection = [[[self class] alloc] initWithDisplayScale:traitCollection.displayScale
                                                   userInterfaceIdiom:traitCollection.userInterfaceIdiom
                                                  horizontalSizeClass:traitCollection.horizontalSizeClass
                                                    verticalSizeClass:traitCollection.verticalSizeClass
                                                 forceTouchCapability:traitCollection.forceTouchCapability
                                               traitCollectionContext:traitCollectionContext];
  }
  else if (AS_AT_LEAST_IOS8) {
    asyncTraitCollection = [[[self class] alloc] initWithDisplayScale:traitCollection.displayScale
                                                   userInterfaceIdiom:traitCollection.userInterfaceIdiom
                                                  horizontalSizeClass:traitCollection.horizontalSizeClass
                                                    verticalSizeClass:traitCollection.verticalSizeClass
                                                 forceTouchCapability:0
                                               traitCollectionContext:traitCollectionContext];
  } else {
    asyncTraitCollection = [[[self class] alloc] init];
  }
  
  return asyncTraitCollection;
}

- (ASEnvironmentTraitCollection)environmentTraitCollection
{
  return (ASEnvironmentTraitCollection) {
    .displayScale = self.displayScale,
    .horizontalSizeClass = self.horizontalSizeClass,
    .userInterfaceIdiom = self.userInterfaceIdiom,
    .verticalSizeClass = self.verticalSizeClass,
    .forceTouchCapability = self.forceTouchCapability,
    .displayContext = self.traitCollectionContext,
  };
}

@end
