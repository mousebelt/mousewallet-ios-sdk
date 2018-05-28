//
//  WSAddress.h
//  BitcoinSPV
//
//  Created by Davide De Rosa on 02/07/14.
//  Copyright (c) 2014 Davide De Rosa. All rights reserved.
//
//  http://github.com/keeshux
//  http://twitter.com/keeshux
//  http://davidederosa.com
//
//  This file is part of BitcoinSPV.
//
//  BitcoinSPV is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BitcoinSPV is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with BitcoinSPV.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Foundation/Foundation.h>

@class WSParameters;
@class WSHash160;

@interface WSAddress : NSObject <NSCopying>

- (instancetype)initWithParameters:(WSParameters *)parameters version:(uint8_t)version hash160:(WSHash160 *)hash160;
- (instancetype)initWithParameters:(WSParameters *)parameters encoded:(NSString *)encoded;
- (WSParameters *)parameters;
- (uint8_t)version;
- (WSHash160 *)hash160;
- (NSString *)encoded;
- (NSString *)hexEncoded;

@end
