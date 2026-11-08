package openlistlib

import (
	"github.com/OpenListTeam/OpenList/v4/cmd"
	"github.com/OpenListTeam/OpenList/v4/cmd/flags"
	"github.com/OpenListTeam/OpenList/v4/internal/model"
	"github.com/OpenListTeam/OpenList/v4/internal/op"
	"github.com/OpenListTeam/OpenList/v4/pkg/utils"
	"github.com/OpenListTeam/OpenList/v4/pkg/utils/random"
)

func SetConfigData(path string) {
	flags.DataDir = path
}

func SetConfigLogStd(b bool) {
	flags.LogStd = b
}

func SetConfigDebug(b bool) {
	flags.Debug = b
}

func SetConfigNoPrefix(b bool) {
	flags.NoPrefix = b
}

func SetAdminPassword(pwd string) {
	admin, err := op.GetAdmin()
	if err != nil {
		utils.Log.Errorf("failed get admin user: %+v", err)
		return
	}
	admin.SetPassword(pwd)
	if err := op.UpdateUser(admin); err != nil {
		utils.Log.Errorf("failed update admin user: %+v", err)
		return
	}
	utils.Log.Infof("admin user has been updated:")
	utils.Log.Infof("username: %s", admin.Username)
	utils.Log.Infof("password: %s", pwd)
	cmd.DelAdminCacheOnline()
}

// EnsureAppUser creates or resets the dedicated user account used by the
// native client UI. It is idempotent: the account is created with full
// admin-level permissions if missing, otherwise its password is reset so the
// app can always log in without touching the real admin account.
// Returns the effective username, or "" on failure.
func EnsureAppUser(username string, password string) string {
	salt := random.String(16)
	user, err := op.GetUserByName(username)
	if err != nil {
		user = &model.User{
			Username:   username,
			PwdHash:    model.TwoHashPwd(password, salt),
			Salt:       salt,
			BasePath:   "/",
			Role:       1, // admin level
			Permission: -1, // all permission bits
			Disabled:   false,
		}
		if err := op.CreateUser(user); err != nil {
			utils.Log.Errorf("failed to create app user %s: %+v", username, err)
			return ""
		}
		utils.Log.Infof("app user %s created", username)
	} else {
		user.PwdHash = model.TwoHashPwd(password, salt)
		user.Salt = salt
		user.BasePath = "/"
		user.Role = 1
		user.Permission = -1
		user.Disabled = false
		if err := op.UpdateUser(user); err != nil {
			utils.Log.Errorf("failed to reset app user %s: %+v", username, err)
			return ""
		}
		utils.Log.Infof("app user %s password reset", username)
	}
	if err := op.DelUserCache(username); err != nil {
		utils.Log.Warnf("failed to refresh app user cache: %+v", err)
	}
	return username
}
