//
//  NetworkError.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/18/26.
//

public enum NetworkError: Error, Equatable {
    case urlError
    case paramError
    case responseError
    case updateFail
}

extension NetworkError {
    public var localizedDescription: String {
        switch self {
        case .urlError:
            return "URL Error"
        case .paramError:
            return "Parameter Error"
        case .responseError:
            return "Response Error"
        case .updateFail:
            return "Bookmark Update Fail"
        }
    }
}
