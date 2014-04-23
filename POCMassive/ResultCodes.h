//
//  ResultCodes.h
//  SPF
//
//  Created by Marco Torres Morgado on 01-06-12.
//  Copyright (c) 2012 SPF. All rights reserved.
//

FOUNDATION_EXPORT int const RESPONSE_OK;                        // Request was correctly processed
FOUNDATION_EXPORT int const RESPONSE_INVALID_REQUEST;           // Missing one or more parameters
FOUNDATION_EXPORT int const RESPONSE_INVALID_CREDENTIALS;       // Credentials couldn't be validated
FOUNDATION_EXPORT int const RESPONSE_REQUEST_TIMEOUT;           // Elapsed time since timestamp timeout
FOUNDATION_EXPORT int const RESPONSE_DEVICE_UNAVAILABLE;        // Identified device inactive or unexistant
FOUNDATION_EXPORT int const RESPONSE_UNKNOWN_ERROR;             // Unexpected error, see pocgateway log
FOUNDATION_EXPORT int const RESPONSE_CREATE_TRANSACTION_ERROR;  // See Transaction log
FOUNDATION_EXPORT int const RESPONSE_RESUME_TRANSACTION_ERROR;  // Requested trx. does not exist or doesn't belong to POC, or isn't current transaction
FOUNDATION_EXPORT int const RESPONSE_VERIFICATION_REJECTED;     // Person's identity was rejected
FOUNDATION_EXPORT int const RESPONSE_VERIFICATION_ERROR;        // Error while validating identity

FOUNDATION_EXPORT int const RESPONSE_NOT_RECOGNIZED;            // No se pudo reconocer a ninguna persona con la imágen entregada.

FOUNDATION_EXPORT int const RESPONSE_FORBIDDEN;                 // El dispositivo no tiene permisos para la acción pedida.

FOUNDATION_EXPORT int const RESPONSE_REJECTED;                  // Hubo un error no especificado (cuando el dispositivo no está en modo debug). Puede producirse por ausencia de las credenciales cuando se envía la petición desde el POC.FOUNDATION_EXPORT int const RESPONSE_RESUME_TRANSACTION_TIMEOUT; // Maximum time since trx. creation elapsed

FOUNDATION_EXPORT int const RESPONSE_DEVICE_DISABLED;
