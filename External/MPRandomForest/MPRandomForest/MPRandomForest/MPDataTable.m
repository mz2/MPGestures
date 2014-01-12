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
    NSArray *_columnTypes;
}
@end

@interface MPRow ()
{
    NSArray *_columnTypes;
    __weak id<MPDataSet> _dataSet;
}
@property (readonly) NSArray *values;
@property (weak, readwrite) id<MPDataSet> dataSet;
@end

#pragma mark - MPDataTable implementation

@implementation MPDataTable

- (NSArray *)datumArray
{
    return [_data copy];
}

- (id)init
{
    @throw [NSException exceptionWithName:@"MPInvalidInitException"
                                   reason:@"Init with -initWithColumnTypes:datumCapacity:"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithColumnTypes:(NSArray *)columnTypes
{
    return [self initWithColumnTypes:columnTypes datumCapacity:0];
}

- (instancetype)initWithColumnTypes:(NSArray *)columnTypes
                      datumCapacity:(NSUInteger)capacity
{
    assert(capacity != NSNotFound);
    
    self = [super init];
    if (self) {
        _columnTypes = columnTypes;
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
    assert(!datum.dataSet);
    
    if (!_columnTypes)
        _columnTypes = datum.columnTypes;
    else
        assert([_columnTypes isEqualToArray:datum.columnTypes]);
    
    [_data addObject:datum];
    [(id)datum setDataSet:self];
}

- (NSArray *)columnTypes
{
    return _columnTypes;
}

@end

#pragma mark - MPRow implementation

@implementation MPRow

- (instancetype)initWithValues:(NSArray *)values columnTypes:(NSArray *)columnTypes
{
    assert(values);
    assert(columnTypes);
    
    assert(values.count == columnTypes.count);
    
    self = [super init];
    if (self) {
        _values = values;
        _columnTypes = columnTypes;
        
        #ifdef DEBUG
        for (NSUInteger i = 0; i < _values.count; i++) {
            [values[i] isKindOfClass:
                [self classForColumnType:
                    (MPColumnType)[_columnTypes[i] unsignedIntegerValue]]];
        }
        #endif
    }
    return self;
}

- (Class)classForColumnType:(MPColumnType)columnType
{
    assert(columnType != MPColumnTypeUnknown);
    
    switch (columnType) {
        case MPColumnTypeIntegral:
            return [NSNumber class];
            break;
        case MPColumnTypeFloatingPoint:
            return [NSNumber class];
        case MPColumnTypeBinary:
            return [NSNumber class];
        case MPColumnTypeCategorical:
            return [NSString class];
        default:
            @throw [NSException exceptionWithName:@"MPUnhandledColumnTypeException"
                                           reason:[NSString stringWithFormat:
                                                   @"Unhandled column type: %lu", columnType] userInfo:nil];
            break;
    }
    
    assert(false);
    return Nil;
}

- (id)valueForColumn:(NSUInteger)index {
    id o = _values[index];
    
    // check that the value is consistent with its type.
    assert([o isKindOfClass:[self classForColumnType:[self typeForColumn:index]]]);
    return o;
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

- (void)setDataSet:(id<MPDataSet>)dataSet {
    assert(!_dataSet); // only call once.
    assert(dataSet); // only call to set the dataset.
    
    _dataSet = dataSet;
    
    if (_columnTypes)
        assert([_columnTypes isEqualToArray:dataSet.columnTypes]);
    else
        _columnTypes = dataSet.columnTypes;
}

- (id<MPDataSet>)dataSet {
    return _dataSet;
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{ @"values":self.values, @"columnTypes":_columnTypes };
}

@end