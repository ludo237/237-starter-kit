interface Model {
    readonly id: string;
    readonly createdAt: string;
    readonly updatedAt: string;
}

interface SoftDeleteModel {
    readonly deletedAt: string | null;
}

interface User extends Model, SoftDeleteModel {
    avatar: string;
    name: string;
    email: string;
    emailVerifiedAt: string | null;
    twoFactor: {
        enabledAt: string | null;
    };
}

interface Team extends Model {
    name: string;
    slug: string;
    isPersonal: boolean;
    role?: TeamRole;
    roleLabel?: string;
    isCurrent?: boolean;
}

interface TeamMember extends Model {
    name: string;
    email: string;
    avatar?: string | null;
    role: TeamRole;
    role_label: string;
}

interface TeamInvitation {
    code: string;
    email: string;
    role: TeamRole;
    role_label: string;
    created_at: string;
}

interface TeamPermissions {
    canUpdateTeam: boolean;
    canDeleteTeam: boolean;
    canAddMember: boolean;
    canUpdateMember: boolean;
    canRemoveMember: boolean;
    canCreateInvitation: boolean;
    canCancelInvitation: boolean;
}

interface RoleOption {
    value: TeamRole;
    label: string;
}
