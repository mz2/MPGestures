//
//  MPNumericalDataSet.m
//  MPRandomForest
//
//  Created by Matias Piipari on 12/01/2014.
//  Copyright (c) 2014 Manuscripts.app Limited. All rights reserved.
//

#import "MPDataTable.h"

@interface MPDataTable ()
{
    NSMutableArray *_data;
}

@property (readonly) NSArray *columnTypes;

@end

@implementation MPDataTable

- (NSArray *)datumArray
{
    return [_data copy];
}

- (instancetype)init
{
    return [self initWithCapacity:0];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
    assert(capacity != NSNotFound);
    
    self = [super init];
    if (self) {
        _data = [NSMutableArray arrayWithCapacity:capacity];
    }
    return self;
}

- (NSUInteger)datumCount {
    return _data.count;
}

- (id<MPDatum>)datumAtIndex:(NSUInteger)i {
    return _data[i];
}

- (NSArray *)arrayOfDictionariesRepresentation
{
    NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:_data.count];
    for (id<MPDatum> datum in _data) {
        [dicts addObject:datum.dictionaryRepresentation];
    }
    return [dicts copy];
}

- (void)appendDatum:(id<MPDatum>)datum
{
    assert(_data);
    assert(_columnTypes);
    
    if (!_columnTypes)
        _columnTypes = datum.columnTypes;
    else
        assert([_columnTypes isEqualToArray:datum.columnTypes]);
    
    [_data addObject:datum];
}

@end

#pragma mark - MPRow implementation

@interface MPRow ()
{
    NSArray *_columnTypes;
    __weak id<MPDataSet> _dataSet;
}
@property (readonly) NSArray *values;
@end

@implementation MPRow

- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes
{
    self = [super init];
    if (self) {
        assert(_values.count == columnTypes.count);
        _values = values;
        _columnTypes = columnTypes;
    }
    return self;
}

- (id)valueForColumn:(NSUInteger)index {
    return _values[index];
}

- (MPColumnType)typeForColumn:(NSUInteger)index {
    return (MPColumnType)[_columnTypes[index] unsignedIntegerValue];
}

- (NSArray *)columnTypes {
    return _columnTypes;
}

- (NSUInteger)columnCount {
    return _values.count;
}

- (id<MPDataSet>)dataSet {
    return _dataSet;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{@"values":self.values, @"columnTypes":_columnTypes};
}

@end